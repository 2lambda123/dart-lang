// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:front_end/src/api_unstable/dart2js.dart' as api;
import 'package:kernel/ast.dart';
import 'package:kernel/class_hierarchy.dart';
import 'package:kernel/core_types.dart';
import 'package:kernel/type_environment.dart';

import '../js_interop.dart' show getJSName;

/// Replaces js_util methods with inline calls to foreign_helper JS which
/// emits the code as a JavaScript code fragment.
class JsUtilOptimizer extends Transformer {
  final Procedure _jsTarget;
  final Procedure _callMethodTarget;
  final List<Procedure> _callMethodUncheckedTargets;
  final Procedure _callConstructorTarget;
  final List<Procedure> _callConstructorUncheckedTargets;
  final Procedure _getPropertyTarget;
  final Procedure _setPropertyTarget;
  final Procedure _setPropertyUncheckedTarget;

  /// Dynamic members in js_util that interop allowed.
  static final Iterable<String> _allowedInteropJsUtilMembers = <String>[
    'callConstructor',
    'callMethod',
    'getProperty',
    'jsify',
    'newObject',
    'setProperty'
  ];
  final Iterable<Procedure> _allowedInteropJsUtilTargets;
  final Procedure _allowInteropTarget;
  final Procedure _listEmptyFactory;

  final CoreTypes _coreTypes;
  final StatefulStaticTypeContext _staticTypeContext;

  JsUtilOptimizer(this._coreTypes, ClassHierarchy hierarchy)
      : _jsTarget =
            _coreTypes.index.getTopLevelProcedure('dart:_foreign_helper', 'JS'),
        _callMethodTarget =
            _coreTypes.index.getTopLevelProcedure('dart:js_util', 'callMethod'),
        _callMethodUncheckedTargets = List<Procedure>.generate(
            5,
            (i) => _coreTypes.index.getTopLevelProcedure(
                'dart:js_util', '_callMethodUnchecked$i')),
        _callConstructorTarget = _coreTypes.index
            .getTopLevelProcedure('dart:js_util', 'callConstructor'),
        _callConstructorUncheckedTargets = List<Procedure>.generate(
            5,
            (i) => _coreTypes.index.getTopLevelProcedure(
                'dart:js_util', '_callConstructorUnchecked$i')),
        _getPropertyTarget = _coreTypes.index
            .getTopLevelProcedure('dart:js_util', 'getProperty'),
        _setPropertyTarget = _coreTypes.index
            .getTopLevelProcedure('dart:js_util', 'setProperty'),
        _setPropertyUncheckedTarget = _coreTypes.index
            .getTopLevelProcedure('dart:js_util', '_setPropertyUnchecked'),
        _allowInteropTarget =
            _coreTypes.index.getTopLevelProcedure('dart:js', 'allowInterop'),
        _allowedInteropJsUtilTargets = _allowedInteropJsUtilMembers.map(
            (member) =>
                _coreTypes.index.getTopLevelProcedure('dart:js_util', member)),
        _listEmptyFactory =
            _coreTypes.index.getProcedure('dart:core', 'List', 'empty'),
        _staticTypeContext = StatefulStaticTypeContext.stacked(
            TypeEnvironment(_coreTypes, hierarchy)) {}

  @override
  visitLibrary(Library lib) {
    _staticTypeContext.enterLibrary(lib);
    lib.transformChildren(this);
    _staticTypeContext.leaveLibrary(lib);
    return lib;
  }

  @override
  defaultMember(Member node) {
    _staticTypeContext.enterMember(node);
    node.transformChildren(this);
    _staticTypeContext.leaveMember(node);
    return node;
  }

  @override
  visitProcedure(Procedure node) {
    _staticTypeContext.enterMember(node);
    // Getters, setters, and fields declared as `static` will be skipped,
    // because they do not have a node.kind of ProcedureKind.Method.
    if (node.isExternal &&
        node.isExtensionMember &&
        node.kind == ProcedureKind.Method) {
      var transformedBody;
      if (api.getExtensionMemberKind(node) == ProcedureKind.Getter) {
        transformedBody = _getExternalGetterBody(node);
      } else if (api.getExtensionMemberKind(node) == ProcedureKind.Setter) {
        transformedBody = _getExternalSetterBody(node);
      }
      // TODO(rileyporter): Add transformation for external extension methods,
      // static members, and any operators we decide to support.
      if (transformedBody != null) {
        node.function.body = transformedBody;
        node.isExternal = false;
      }
    } else {
      node.transformChildren(this);
    }
    _staticTypeContext.leaveMember(node);
    return node;
  }

  /// Returns a new function body for the given [node] external getter.
  ///
  /// The new function body will call the optimized version of
  /// `js_util.getProperty` for the given external getter.
  ReturnStatement _getExternalGetterBody(Procedure node) {
    var function = node.function;
    assert(function.positionalParameters.length == 1);
    var getPropertyInvocation = StaticInvocation(
        _getPropertyTarget,
        Arguments([
          VariableGet(function.positionalParameters.first),
          StringLiteral(_getMemberName(node))
        ]))
      ..fileOffset = node.fileOffset;
    return ReturnStatement(AsExpression(
        _lowerGetProperty(getPropertyInvocation), function.returnType));
  }

  /// Returns a new function body for the given [node] external setter.
  ///
  /// The new function body will call the optimized version of
  /// `js_util.setProperty` for the given external setter.
  ReturnStatement _getExternalSetterBody(Procedure node) {
    var function = node.function;
    assert(function.positionalParameters.length == 2);
    var setPropertyInvocation = StaticInvocation(
        _setPropertyTarget,
        Arguments([
          VariableGet(function.positionalParameters.first),
          StringLiteral(_getMemberName(node)),
          VariableGet(function.positionalParameters.last)
        ]))
      ..fileOffset = node.fileOffset;
    return ReturnStatement(AsExpression(
        _lowerSetProperty(setPropertyInvocation), function.returnType));
  }

  /// Returns the member name, either from the `@JS` annotation if non-empty,
  /// or parsed from CFE generated node name.
  String _getMemberName(Procedure node) {
    var jsAnnotationName = getJSName(node);
    return jsAnnotationName.isNotEmpty
        ? jsAnnotationName
        : node.name.text.substring(node.name.text.indexOf('#') + 1);
  }

  /// Replaces js_util method calls with optimization when possible.
  ///
  /// Lowers `getProperty` for any argument type straight to JS fragment call.
  /// Lowers `setProperty` to `_setPropertyUnchecked` for values that are
  /// not Function type and guaranteed to be interop allowed.
  /// Lowers `callMethod` to `_callMethodUncheckedN` when the number of given
  /// arguments is 0-4 and all arguments are guaranteed to be interop allowed.
  @override
  visitStaticInvocation(StaticInvocation node) {
    if (node.target == _getPropertyTarget) {
      node = _lowerGetProperty(node);
    } else if (node.target == _setPropertyTarget) {
      node = _lowerSetProperty(node);
    } else if (node.target == _callMethodTarget) {
      node = _lowerCallMethod(node);
    } else if (node.target == _callConstructorTarget) {
      node = _lowerCallConstructor(node);
    }
    node.transformChildren(this);
    return node;
  }

  /// Lowers the given js_util `getProperty` call to the foreign_helper JS call
  /// for any argument type. Lowers `getProperty(o, name)` to
  /// `JS('Object|Null', '#.#', o, name)`.
  StaticInvocation _lowerGetProperty(StaticInvocation node) {
    Arguments arguments = node.arguments;
    assert(arguments.types.isEmpty);
    assert(arguments.positional.length == 2);
    assert(arguments.named.isEmpty);
    return StaticInvocation(
        _jsTarget,
        Arguments(
          [
            StringLiteral("Object|Null"),
            StringLiteral("#.#"),
            ...arguments.positional
          ],
          // TODO(rileyporter): Copy type from getProperty when it's generic.
          types: [DynamicType()],
        )..fileOffset = arguments.fileOffset)
      ..fileOffset = node.fileOffset;
  }

  /// Lowers the given js_util `setProperty` call to `_setPropertyUnchecked`
  /// when the additional validation checks in `setProperty` can be elided.
  ///
  /// Removing the checks allows further inlining by the compilers.
  StaticInvocation _lowerSetProperty(StaticInvocation node) {
    Arguments arguments = node.arguments;
    assert(arguments.types.isEmpty);
    assert(arguments.positional.length == 3);
    assert(arguments.named.isEmpty);

    if (!_allowedInterop(arguments.positional.last)) {
      return node;
    }

    return StaticInvocation(_setPropertyUncheckedTarget, arguments)
      ..fileOffset = node.fileOffset;
  }

  /// Lowers the given js_util `callMethod` call to `_callMethodUncheckedN`
  /// when the additional validation checks on the arguments can be elided.
  ///
  /// Calls will be lowered when using a List literal or constant list with 0-4
  /// elements for the `callMethod` arguments, or the `List.empty()` factory.
  /// Removing the checks allows further inlining by the compilers.
  StaticInvocation _lowerCallMethod(StaticInvocation node) {
    Arguments arguments = node.arguments;
    assert(arguments.types.isEmpty);
    assert(arguments.positional.length == 3);
    assert(arguments.named.isEmpty);

    return _lowerToCallUnchecked(
        node, _callMethodUncheckedTargets, arguments.positional.sublist(0, 2));
  }

  /// Lowers the given js_util `callConstructor` call to `_callConstructorUncheckedN`
  /// when the additional validation checks on the arguments can be elided.
  ///
  /// Calls will be lowered when using a List literal or constant list with 0-4
  /// elements for the `callConstructor` arguments, or the `List.empty()` factory.
  /// Removing the checks allows further inlining by the compilers.
  StaticInvocation _lowerCallConstructor(StaticInvocation node) {
    Arguments arguments = node.arguments;
    assert(arguments.types.isEmpty);
    assert(arguments.positional.length == 2);
    assert(arguments.named.isEmpty);

    return _lowerToCallUnchecked(
        node, _callConstructorUncheckedTargets, [arguments.positional.first]);
  }

  /// Helper to lower the given [node] to the relevant unchecked target in the
  /// [callUncheckedTargets] based on whether the validation checks on the
  /// [originalArguments] can be elided.
  ///
  /// Calls will be lowered when using a List literal or constant list with 0-4
  /// arguments, or the `List.empty()` factory. Removing the checks allows further
  /// inlining by the compilers.
  StaticInvocation _lowerToCallUnchecked(
      StaticInvocation node,
      List<Procedure> callUncheckedTargets,
      List<Expression> originalArguments) {
    var argumentsList = node.arguments.positional.last;
    // Lower arguments in a List.empty factory call.
    if (argumentsList is StaticInvocation &&
        argumentsList.target == _listEmptyFactory) {
      return _createCallUncheckedNode(callUncheckedTargets, [],
          originalArguments, node.fileOffset, node.arguments.fileOffset);
    }

    // Lower arguments in other kinds of Lists.
    var callUncheckedArguments;
    var entryType;
    if (argumentsList is ListLiteral) {
      if (argumentsList.expressions.length >= callUncheckedTargets.length) {
        return node;
      }
      callUncheckedArguments = argumentsList.expressions;
      entryType = argumentsList.typeArgument;
    } else if (argumentsList is ConstantExpression &&
        argumentsList.constant is ListConstant) {
      var argumentsListConstant = argumentsList.constant as ListConstant;
      if (argumentsListConstant.entries.length >= callUncheckedTargets.length) {
        return node;
      }
      callUncheckedArguments = argumentsListConstant.entries
          .map((constant) => ConstantExpression(
              constant, constant.getType(_staticTypeContext)))
          .toList();
      entryType = argumentsListConstant.typeArgument;
    } else {
      // Skip lowering arguments in any other type of List.
      return node;
    }

    // Check the arguments List type, then verify each argument if needed.
    if (!_allowedInteropType(entryType)) {
      for (var argument in callUncheckedArguments) {
        if (!_allowedInterop(argument)) {
          return node;
        }
      }
    }

    return _createCallUncheckedNode(
        callUncheckedTargets,
        callUncheckedArguments,
        originalArguments,
        node.fileOffset,
        node.arguments.fileOffset);
  }

  /// Creates a new StaticInvocation node for the relevant unchecked target
  /// with the given 0-4 arguments.
  StaticInvocation _createCallUncheckedNode(
      List<Procedure> callUncheckedTargets,
      List<Expression> callUncheckedArguments,
      List<Expression> originalArguments,
      int nodeFileOffset,
      int argumentsFileOffset) {
    assert(callUncheckedArguments.length <= 4);
    return StaticInvocation(
        callUncheckedTargets[callUncheckedArguments.length],
        Arguments(
          [...originalArguments, ...callUncheckedArguments],
          types: [],
        )..fileOffset = argumentsFileOffset)
      ..fileOffset = nodeFileOffset;
  }

  /// Returns whether the given Expression is guaranteed to be allowed to
  /// interop with JS.
  ///
  /// Returns true when the node is guaranteed to be not a function:
  ///    - has a static DartType that is NullType or an InterfaceType that is
  ///      not Function or Object
  /// Also returns true for allowed method calls within the JavaScript domain:
  ///        - dart:_foreign_helper JS
  ///        - dart:js `allowInterop`
  ///        - dart:js_util and any of the `_allowedInteropJsUtilMembers`
  bool _allowedInterop(Expression node) {
    // TODO(rileyporter): Detect functions that have been wrapped at some point
    // with `allowInterop`
    if (node is StaticInvocation) {
      if (node.target == _allowInteropTarget) return true;
      if (node.target == _jsTarget) return true;
      if (_allowedInteropJsUtilTargets.contains(node.target)) return true;
    }

    return _allowedInteropType(node.getStaticType(_staticTypeContext));
  }

  /// Returns whether the given DartType is guaranteed to be not a function
  /// and therefore allowed to interop with JS.
  bool _allowedInteropType(DartType type) {
    if (type is InterfaceType) {
      return type.classNode != _coreTypes.functionClass &&
          type.classNode != _coreTypes.objectClass;
    } else {
      // Only other DartType guaranteed to not be a function.
      return type is NullType;
    }
  }
}
