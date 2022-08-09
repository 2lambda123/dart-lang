// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analysis_server/src/services/correction/assist.dart';
import 'package:analysis_server/src/services/correction/dart/abstract_producer.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer_plugin/utilities/assist/assist.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';

class EncapsulateField extends CorrectionProducer {
  @override
  AssistKind get assistKind => DartAssistKind.ENCAPSULATE_FIELD;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    // find FieldDeclaration
    var fieldDeclaration = node.thisOrAncestorOfType<FieldDeclaration>();
    if (fieldDeclaration == null) {
      return;
    }
    // not interesting for static
    if (fieldDeclaration.isStatic) {
      return;
    }
    // has a parse error
    var variableList = fieldDeclaration.fields;
    if (variableList.keyword == null && variableList.type == null) {
      return;
    }
    // not interesting for final
    if (variableList.isFinal) {
      return;
    }
    // should have exactly one field
    List<VariableDeclaration> fields = variableList.variables;
    if (fields.length != 1) {
      return;
    }
    var field = fields.first;
    var nameToken = field.name2;
    var fieldElement = field.declaredElement as FieldElement;
    // should have a public name
    var name = nameToken.lexeme;
    if (Identifier.isPrivateName(name)) {
      return;
    }
    // should be on the name
    if (nameToken != token) {
      return;
    }

    // Should be in a class or mixin.
    List<ClassMember> classMembers;
    final parent = fieldDeclaration.parent;
    if (parent is ClassDeclaration) {
      classMembers = parent.members;
    } else if (parent is MixinDeclaration) {
      classMembers = parent.members;
    } else {
      return;
    }

    await builder.addDartFileEdit(file, (builder) {
      // rename field
      builder.addSimpleReplacement(range.token(nameToken), '_$name');
      // update references in constructors
      for (var member in classMembers) {
        if (member is ConstructorDeclaration) {
          for (var parameter in member.parameters.parameters) {
            var identifier = parameter.name;
            var parameterElement = parameter.declaredElement;
            if (identifier != null &&
                parameterElement is FieldFormalParameterElement &&
                parameterElement.field == fieldElement) {
              builder.addSimpleReplacement(range.token(identifier), '_$name');
            }
          }
        }
      }

      // Write getter and setter.
      builder.addInsertion(fieldDeclaration.end, (builder) {
        String? docCode;
        var documentationComment = fieldDeclaration.documentationComment;
        if (documentationComment != null) {
          docCode = utils.getNodeText(documentationComment);
        }

        var typeCode = '';
        var typeAnnotation = variableList.type;
        if (typeAnnotation != null) {
          typeCode = '${utils.getNodeText(typeAnnotation)} ';
        }

        // Write getter.
        builder.writeln();
        builder.writeln();
        if (docCode != null) {
          builder.write('  ');
          builder.writeln(docCode);
        }
        builder.write('  ${typeCode}get $name => _$name;');

        // Write setter.
        builder.writeln();
        builder.writeln();
        if (docCode != null) {
          builder.write('  ');
          builder.writeln(docCode);
        }
        builder.writeln('  set $name($typeCode$name) {');
        builder.writeln('    _$name = $name;');
        builder.write('  }');
      });
    });
  }
}
