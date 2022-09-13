// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:analysis_server/lsp_protocol/protocol.dart';
import 'package:analysis_server/src/lsp/mapping.dart';
import 'package:analyzer/source/line_info.dart';
import 'package:test/test.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import 'server_abstract.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(TypeInlayHintTest);
  });
}

@reflectiveTest
class TypeInlayHintTest extends AbstractLspAnalysisServerTest {
  /// Substitutes text from [hints] into [content] to produce a text
  /// representation that can be easily tested.
  ///
  /// Label kinds will be included as well as their text, with leading or
  /// trailing spaces based on padding flags on the hint.
  ///
  /// ```
  /// final a = 1;
  /// ```
  ///
  /// May become:
  ///
  /// ```
  /// final (Type:int) a = 1;
  /// ```
  String substituteHints(String content, List<InlayHint> hints) {
    hints.sort((h1, h2) => positionCompare(h1.position, h2.position));
    final buffer = StringBuffer();
    final lineInfo = LineInfo.fromContent(content);

    var lastOffset = 0;
    for (final hint in hints) {
      // First add any text from the last hint up to this hint.
      final offset = toOffset(lineInfo, hint.position).result;
      buffer.write(content.substring(lastOffset, offset));

      // Then add the hint. Include the kind in parens so it can be tested too,
      // and add a trailing/leading space based on settings.
      _writeHintDescription(buffer, hint);
      lastOffset = offset;
    }
    // Finally, write anything after the last hint.
    buffer.write(content.substring(lastOffset));

    return buffer.toString();
  }

  Future<void> test_class_field() async {
    final content = '''
class A {
  final i1 = 1;
}
''';
    final expected = '''
class A {
  final (Type:int) i1 = 1;
}
''';
    await _testHints(content, expected);
  }

  Future<void> test_documentUpdates() async {
    final content = '''
final a = 1;
''';
    await initialize();

    // Start with a blank document expecting no hints,
    await openFile(mainFileUri, '');
    final hintsBeforeChange = await getInlayHints(
      mainFileUri,
      startOfDocRange,
    );

    // Update the document to ensure we get latest hints.
    // Don't await `replaceFile` because we want to check the server correctly
    // handles an inlayHints request that immediately follows a document update.
    unawaited(replaceFile(1, mainFileUri, content));
    final hintsAfterChange = await getInlayHints(
      mainFileUri,
      rangeOfWholeContent(content),
    );

    expect(hintsBeforeChange, isEmpty);
    expect(hintsAfterChange, isNotEmpty);
  }

  Future<void> test_localFunction_returnType() async {
    // Check inferred return types for local functions have type hints.
    final content = '''
void f() {
  g() => '';
  h() { return ''; }
  i() {}
  void j() {}
}
''';
    final expected = '''
void f() {
  (Type:String) g() => '';
  (Type:String) h() { return ''; }
  (Type:Null) i() {}
  void j() {}
}
''';
    await _testHints(content, expected);
  }

  Future<void> test_method_parameters() async {
    final content = '''
class A {
  void m1(int a, [String? b]) {}
  void m2(int a, {String? b, required String c}) {}
}
class B extends A {
  @override
  void m1(a, [b]) {}
  void m2(a, {b, required c}) {}
  void m3(a, {b}) {}
}
''';
    final expected = '''
class A {
  void m1(int a, [String? b]) {}
  void m2(int a, {String? b, required String c}) {}
}
class B extends A {
  @override
  void m1((Type:int) a, [(Type:String?) b]) {}
  void m2((Type:int) a, {(Type:String?) b, required (Type:String) c}) {}
  void m3((Type:dynamic) a, {(Type:dynamic) b}) {}
}
''';
    await _testHints(content, expected);
  }

  Future<void> test_method_returnType() async {
    final content = '''
class A {
  f() => '';
}
''';
    // method return types are not inferred and always `dynamic`.
    final expected = '''
class A {
  (Type:dynamic) f() => '';
}
''';
    await _testHints(content, expected);
  }

  Future<void> test_topLevelFunction_returnType() async {
    final content = '''
f() => '';
''';
    // top-level function return types are not inferred and always `dynamic`
    final expected = '''
(Type:dynamic) f() => '';
''';
    await _testHints(content, expected);
  }

  Future<void> test_topLevelVariable_closureResult() async {
    final content = '''
var c1 = (() => 3)();
int c2 = (() => 3)(); // already typed
''';
    final expected = '''
var (Type:int) c1 = (() => 3)();
int c2 = (() => 3)(); // already typed
''';
    await _testHints(content, expected);
  }

  Future<void> test_topLevelVariable_functionResult() async {
    final content = '''
String f() => '';
final s1 = f();
final String s2 = f(); // already typed
''';
    final expected = '''
String f() => '';
final (Type:String) s1 = f();
final String s2 = f(); // already typed
''';
    await _testHints(content, expected);
  }

  Future<void> test_topLevelVariable_functionType() async {
    final content = '''
final f1 = (List<String> x) => x;
final List<String> Function(List<String>) f2 = (List<String> x) => x; // already typed
''';
    final expected = '''
final (Type:List<String> Function(List<String>)) f1 = (List<String> x) => x;
final List<String> Function(List<String>) f2 = (List<String> x) => x; // already typed
''';
    await _testHints(content, expected);
  }

  Future<void> test_topLevelVariable_literal() async {
    final content = '''
final i1 = 1;
const i2 = 1;
var i3 = 1;
final i4 = 2, s1 = '';
int i5 = 1; // already typed
''';
    final expected = '''
final (Type:int) i1 = 1;
const (Type:int) i2 = 1;
var (Type:int) i3 = 1;
final (Type:int) i4 = 2, (Type:String) s1 = '';
int i5 = 1; // already typed
''';
    await _testHints(content, expected);
  }

  Future<void> test_topLevelVariable_literalList() async {
    final content = '''
final l1 = [1, 2, 3];
final l2 = [1, '', 3];
final l3 = ['', null, ''];
final l4 = <Object>[1, 2, 3];
final List<Object> l5 = [1, 2, 3]; // already typed
''';
    final expected = '''
final (Type:List<int>) l1 = [1, 2, 3];
final (Type:List<Object>) l2 = [1, '', 3];
final (Type:List<String?>) l3 = ['', null, ''];
final (Type:List<Object>) l4 = <Object>[1, 2, 3];
final List<Object> l5 = [1, 2, 3]; // already typed
''';
    await _testHints(content, expected);
  }

  Future<void> test_topLevelVariable_literalMap() async {
    final content = '''
final m1 = {1: '', 2: ''};
final m2 = {'': [1]};
final m3 = {'': null};
final m4 = <Object, String>{1: '', 2: ''};
final Map<int, String> m1 = {1: '', 2: ''}; // already typed
''';
    final expected = '''
final (Type:Map<int, String>) m1 = {1: '', 2: ''};
final (Type:Map<String, List<int>>) m2 = {'': [1]};
final (Type:Map<String, Null>) m3 = {'': null};
final (Type:Map<Object, String>) m4 = <Object, String>{1: '', 2: ''};
final Map<int, String> m1 = {1: '', 2: ''}; // already typed
''';
    await _testHints(content, expected);
  }

  Future<void> test_topLevelVariable_literalSet() async {
    final content = '''
final s1 = {1, 2, 3};
final s2 = {1, '', 3};
final s3 = {'', null, ''};
final s4 = <Object>{1, 2, 3};
final Set<Object> s5 = {1, 2, 3}; // already typed
''';
    final expected = '''
final (Type:Set<int>) s1 = {1, 2, 3};
final (Type:Set<Object>) s2 = {1, '', 3};
final (Type:Set<String?>) s3 = {'', null, ''};
final (Type:Set<Object>) s4 = <Object>{1, 2, 3};
final Set<Object> s5 = {1, 2, 3}; // already typed
''';
    await _testHints(content, expected);
  }

  Future<void> _testHints(
      String content, String expectedContentWithHints) async {
    await initialize();

    await openFile(mainFileUri, content);
    final hints = await getInlayHints(
      mainFileUri,
      rangeOfWholeContent(content),
    );

    final actualContentWithHints = substituteHints(content, hints);
    expect(actualContentWithHints, expectedContentWithHints);
  }

  /// Helper to write a text representation of [hint] into [buffer].
  void _writeHintDescription(StringBuffer buffer, InlayHint hint) {
    // TODO(dantup): Improve the LSP enum codegen to allow us to get the names
    //  of int-based enums.
    final kindNames = {
      InlayHintKind.Type: 'Type',
      InlayHintKind.Parameter: 'Parameter',
    };

    if (hint.paddingLeft ?? false) {
      buffer.write(' ');
    }
    buffer.write('(');
    if (hint.kind != null) {
      buffer
        ..write(kindNames[hint.kind])
        ..write(':');
    }
    buffer.write(hint.textLabel);
    buffer.write(')');
    if (hint.paddingRight ?? false) {
      buffer.write(' ');
    }
  }
}

extension _InlayHintExtension on InlayHint {
  /// Returns the visible text of the InlayHint, concatenating any parts.
  String get textLabel => label.map(
        // Unwrap where an InlayHint may provide its label in multiple
        // `InlayHintLabelPart`s.
        (t1) => t1.map((part) => part.value).join(),
        (t2) => t2,
      );
}
