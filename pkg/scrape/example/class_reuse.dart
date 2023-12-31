// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:scrape/scrape.dart';

void main(List<String> arguments) {
  Scrape()
    ..addHistogram('Declarations')
    ..addHistogram('Uses')
    ..addHistogram('Superclass names')
    ..addHistogram('Superinterface names')
    ..addHistogram('Mixin names')
    ..addVisitor(ClassReuseVisitor.new)
    ..runCommandLine(arguments);
}

class ClassReuseVisitor extends ScrapeVisitor {
  @override
  void visitClassDeclaration(ClassDeclaration node) {
    if (node.abstractKeyword != null) {
      record('Declarations', 'abstract class');
    } else {
      record('Declarations', 'class');
    }

    var extendsClause = node.extendsClause;
    if (extendsClause != null) {
      record('Uses', 'extend');
      record('Superclass names', extendsClause.superclass.toString());
    }

    var withClause = node.withClause;
    if (withClause != null) {
      for (var mixin in withClause.mixinTypes) {
        record('Uses', 'mixin');
        record('Mixin names', mixin.toString());
      }
    }

    var implementsClause = node.implementsClause;
    if (implementsClause != null) {
      for (var type in implementsClause.interfaces) {
        record('Uses', 'implement');
        record('Superinterface names', type.toString());
      }
    }
  }
}
