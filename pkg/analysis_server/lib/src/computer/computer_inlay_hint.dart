// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analysis_server/lsp_protocol/protocol.dart';
import 'package:analysis_server/src/lsp/mapping.dart';
import 'package:analysis_server/src/utilities/extensions/ast.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/syntactic_entity.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/source/line_info.dart';

/// A computer for LSP Inlay Hints.
///
/// Inlay hints are text labels used to show inferred labels such as type and
/// argument names where they are not already explicitly present in the source
/// but are being inferred.
class DartInlayHintComputer {
  final LineInfo _lineInfo;
  final CompilationUnit _unit;
  final bool _isNonNullableByDefault;
  final List<InlayHint> _hints = [];

  DartInlayHintComputer(ResolvedUnitResult result)
      : _unit = result.unit,
        _lineInfo = result.lineInfo,
        _isNonNullableByDefault = result.unit.isNonNullableByDefault;

  List<InlayHint> compute() {
    _unit.accept(_DartInlayHintComputerVisitor(this));
    return _hints;
  }

  /// Adds a parameter name hint before [node] showing a label for [name].
  ///
  /// A colon and padding will be added between the hint and [node]
  /// automatically.
  void _addParameterNamePrefix(SyntacticEntity nodeOrToken, String name) {
    final offset = nodeOrToken.offset;
    final position = toPosition(_lineInfo.getLocation(offset));
    final labelParts = Either2<List<InlayHintLabelPart>, String>.t2('$name:');
    _hints.add(InlayHint(
      label: labelParts,
      position: position,
      kind: InlayHintKind.Parameter,
      paddingRight: true,
    ));
  }

  /// Adds a type hint before [node] showing a label for the type [type].
  ///
  /// Padding will be added between the hint and [node] automatically.
  void _addTypePrefix(SyntacticEntity nodeOrToken, DartType type) {
    final offset = nodeOrToken.offset;
    final position = toPosition(_lineInfo.getLocation(offset));
    final label =
        type.getDisplayString(withNullability: _isNonNullableByDefault);
    final labelParts = Either2<List<InlayHintLabelPart>, String>.t2(label);
    _hints.add(InlayHint(
      label: labelParts,
      position: position,
      kind: InlayHintKind.Type,
      paddingRight: true,
    ));
  }
}

/// An AST visitor for [DartInlayHintComputer].
class _DartInlayHintComputerVisitor extends GeneralizingAstVisitor<void> {
  final DartInlayHintComputer _computer;

  _DartInlayHintComputerVisitor(this._computer);

  @override
  void visitArgumentList(ArgumentList node) {
    super.visitArgumentList(node);

    for (final argument in node.arguments) {
      if (argument is! NamedExpression) {
        final parameter = argument.staticParameterElement;
        if (parameter != null) {
          _computer._addParameterNamePrefix(argument, parameter.name);
        }
      }
    }
  }

  @override
  void visitFunctionDeclaration(FunctionDeclaration node) {
    super.visitFunctionDeclaration(node);

    // Has explicit type.
    if (node.returnType != null) {
      return;
    }

    final declaration = node.declaredElement2;
    if (declaration != null) {
      // For getters/setters, the type must come before the property keyword,
      // not the name.
      final token = node.propertyKeyword ?? node.name2;
      _computer._addTypePrefix(token, declaration.returnType);
    }
  }

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    super.visitMethodDeclaration(node);

    // Has explicit type.
    if (node.returnType != null) {
      return;
    }

    final declaration = node.declaredElement2;
    if (declaration != null) {
      _computer._addTypePrefix(node.name2, declaration.returnType);
    }
  }

  @override
  void visitSimpleFormalParameter(SimpleFormalParameter node) {
    super.visitSimpleFormalParameter(node);

    // Has explicit type.
    if (node.isExplicitlyTyped) {
      return;
    }

    final declaration = node.declaredElement;
    if (declaration != null) {
      // Prefer to insert before `name` to avoid going before keywords like
      // `required`.
      _computer._addTypePrefix(node.name ?? node, declaration.type);
    }
  }

  @override
  void visitVariableDeclaration(VariableDeclaration node) {
    super.visitVariableDeclaration(node);

    final parent = node.parent;
    // Unexpected parent or has explicit type.
    if (parent is! VariableDeclarationList || parent.type != null) {
      return;
    }

    final declaration = node.declaredElement2;
    if (declaration != null) {
      _computer._addTypePrefix(node, declaration.type);
    }
  }
}
