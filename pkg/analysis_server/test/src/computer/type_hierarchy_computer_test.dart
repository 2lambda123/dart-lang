// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analysis_server/src/computer/computer_lazy_type_hierarchy.dart';
import 'package:analysis_server/src/services/search/search_engine.dart';
import 'package:analysis_server/src/services/search/search_engine_internal.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:test/test.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../../abstract_single_unit.dart';
import '../../utils/test_code_format.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(TypeHierarchyComputerFindTargetTest);
    defineReflectiveTests(TypeHierarchyComputerFindSupertypesTest);
    defineReflectiveTests(TypeHierarchyComputerFindSubtypesTest);
  });
}

abstract class AbstractTypeHierarchyTest extends AbstractSingleUnitTest {
  final startOfFile = SourceRange(0, 0);
  late TestCode code;

  /// Matches a [TypeHierarchyItem] for [Object].
  Matcher get _isObject => TypeMatcher<TypeHierarchyItem>()
      .having((e) => e.displayName, 'displayName', 'Object')
      // Check some basic things without hard-coding values that will make
      // this test brittle.
      .having((e) => e.file, 'file', convertPath('/sdk/lib/core/core.dart'))
      .having((e) => e.nameRange.offset, 'nameRange.offset', isPositive)
      .having((e) => e.nameRange.length, 'nameRange.length', 'Object'.length)
      .having((e) => e.codeRange.offset, 'codeRange.offset', isPositive)
      .having((e) => e.codeRange.length, 'codeRange.length',
          greaterThan('class Object {}'.length));

  @override
  void addTestSource(String content) {
    code = TestCode.parse(content);
    super.addTestSource(code.code);
  }

  Future<TypeHierarchyItem?> findTarget() async {
    expect(code, isNotNull, reason: 'addTestSource should be called first');
    final result = await getResolvedUnit(testFile);
    return DartLazyTypeHierarchyComputer(result)
        .findTarget(code.position.offset);
  }

  Future<ResolvedUnitResult> getResolvedUnit(String file) async =>
      await (await session).getResolvedUnit(file) as ResolvedUnitResult;

  /// Matches a [TypeHierarchyItem] with the given name/kind/file.
  Matcher _isItem(
    String displayName,
    String file, {
    required SourceRange nameRange,
    required SourceRange codeRange,
  }) =>
      TypeMatcher<TypeHierarchyItem>()
          .having((e) => e.displayName, 'displayName', displayName)
          .having((e) => e.file, 'file', file)
          .having((e) => e.nameRange, 'nameRange', nameRange)
          .having((e) => e.codeRange, 'codeRange', codeRange);
}

@reflectiveTest
class TypeHierarchyComputerFindSubtypesTest extends AbstractTypeHierarchyTest {
  late SearchEngine searchEngine;

  Future<List<TypeHierarchyItem>?> findSubtypes(
      TypeHierarchyItem target) async {
    final result = await getResolvedUnit(target.file);
    return DartLazyTypeHierarchyComputer(result)
        .findSubtypes(target, searchEngine);
  }

  @override
  void setUp() {
    super.setUp();
    searchEngine = SearchEngineImpl([
      driverFor(testPackageRootPath),
    ]);
  }

  Future<void> test_class_mixins() async {
    final content = '''
/*[0*/class /*[1*/MyClass1/*1]*/ with MyMixin1 {}/*0]*/
/*[2*/class /*[3*/MyClass2/*3]*/ with MyMixin1 {}/*2]*/
mixin MyMi^xin1 {}
    ''';

    addTestSource(content);
    final target = await findTarget();
    final subtypes = await findSubtypes(target!);
    expect(subtypes, [
      _isItem(
        'MyClass1',
        testFile,
        codeRange: code.ranges[0].sourceRange,
        nameRange: code.ranges[1].sourceRange,
      ),
      _isItem(
        'MyClass2',
        testFile,
        codeRange: code.ranges[2].sourceRange,
        nameRange: code.ranges[3].sourceRange,
      ),
    ]);
  }

  Future<void> test_class_superclass() async {
    final content = '''
class ^MyClass1 {}
/*[0*/class /*[1*/MyClass2/*1]*/ extends MyClass1 {}/*0]*/
    ''';

    addTestSource(content);
    final target = await findTarget();
    final supertypes = await findSubtypes(target!);
    expect(supertypes, [
      _isItem(
        'MyClass2',
        testFile,
        codeRange: code.ranges[0].sourceRange,
        nameRange: code.ranges[1].sourceRange,
      ),
    ]);
  }

  Future<void> test_mixin() async {
    final content = '''
class MyCl^ass1 {}
/*[0*/mixin /*[1*/MyMixin1/*1]*/ on MyClass1 {}/*0]*/
    ''';

    addTestSource(content);
    final target = await findTarget();
    final supertypes = await findSubtypes(target!);
    expect(supertypes, [
      _isItem(
        'MyMixin1',
        testFile,
        codeRange: code.ranges[0].sourceRange,
        nameRange: code.ranges[1].sourceRange,
      ),
    ]);
  }
}

@reflectiveTest
class TypeHierarchyComputerFindSupertypesTest
    extends AbstractTypeHierarchyTest {
  Future<List<TypeHierarchyItem>?> findSupertypes(
      TypeHierarchyItem target) async {
    final result = await getResolvedUnit(target.file);
    return DartLazyTypeHierarchyComputer(result).findSupertypes(target);
  }

  /// Test that if the file is modified between fetching a target and it's
  /// sub/supertypes it can still be located (by name).
  Future<void> test_class_afterModification() async {
    final content = '''
/*[0*/class /*[1*/MyClass1/*1]*/ {}/*0]*/
class ^MyClass2 extends MyClass1 {}
    ''';

    addTestSource(content);
    final target = await findTarget();

    // Update the content so that offsets have changed since we got `target`.
    addTestSource('// extra\n$content');

    final supertypes = await findSupertypes(target!);
    expect(supertypes, [
      _isItem(
        'MyClass1',
        testFile,
        codeRange: code.ranges[0].sourceRange,
        nameRange: code.ranges[1].sourceRange,
      ),
    ]);
  }

  Future<void> test_class_mixins() async {
    final content = '''
/*[0*/mixin /*[1*/MyMixin1/*1]*/ {}/*0]*/
/*[2*/mixin /*[3*/MyMixin2/*3]*/ {}/*2]*/
class ^MyClass1 with MyMixin1, MyMixin2 {}
    ''';

    addTestSource(content);
    final target = await findTarget();
    final supertypes = await findSupertypes(target!);
    expect(supertypes, [
      _isObject,
      _isItem(
        'MyMixin1',
        testFile,
        codeRange: code.ranges[0].sourceRange,
        nameRange: code.ranges[1].sourceRange,
      ),
      _isItem(
        'MyMixin2',
        testFile,
        codeRange: code.ranges[2].sourceRange,
        nameRange: code.ranges[3].sourceRange,
      ),
    ]);
  }

  Future<void> test_class_superclass() async {
    final content = '''
/*[0*/class /*[1*/MyClass1/*1]*/ {}/*0]*/
class ^MyClass2 extends MyClass1 {}
    ''';

    addTestSource(content);
    final target = await findTarget();
    final supertypes = await findSupertypes(target!);
    expect(supertypes, [
      _isItem(
        'MyClass1',
        testFile,
        codeRange: code.ranges[0].sourceRange,
        nameRange: code.ranges[1].sourceRange,
      ),
    ]);
  }

  /// Mixins have no supertypes and are provided only for subtype search,
  /// mirroring that they appear in the supertypes list of classes.
  Future<void> test_mixin() async {
    final content = '''
class MyClass1 {}
mixin MyMix^in2 on MyClass1 {}
    ''';

    addTestSource(content);
    final target = await findTarget();
    final supertypes = await findSupertypes(target!);
    expect(supertypes, isEmpty);
  }
}

@reflectiveTest
class TypeHierarchyComputerFindTargetTest extends AbstractTypeHierarchyTest {
  Future<void> expectNoTarget() async {
    await expectTarget(isNull);
  }

  Future<void> expectTarget(Matcher matcher) async {
    final target = await findTarget();
    expect(target, matcher);
  }

  Future<void> test_class_body() async {
    final content = '''
/*[0*/class /*[1*/MyClass1/*1]*/ {
  int? a^;
}/*0]*/
    ''';

    addTestSource(content);
    await expectTarget(
      _isItem(
        'MyClass1',
        testFile,
        codeRange: code.ranges[0].sourceRange,
        nameRange: code.ranges[1].sourceRange,
      ),
    );
  }

  Future<void> test_class_keyword() async {
    final content = '''
/*[0*/cla^ss /*[1*/MyClass1/*1]*/ {
}/*0]*/
    ''';

    addTestSource(content);
    await expectTarget(
      _isItem(
        'MyClass1',
        testFile,
        codeRange: code.ranges[0].sourceRange,
        nameRange: code.ranges[1].sourceRange,
      ),
    );
  }

  Future<void> test_class_name() async {
    final content = '''
/*[0*/class /*[1*/MyCla^ss1/*1]*/ {
}/*0]*/
    ''';

    addTestSource(content);
    await expectTarget(
      _isItem(
        'MyClass1',
        testFile,
        codeRange: code.ranges[0].sourceRange,
        nameRange: code.ranges[1].sourceRange,
      ),
    );
  }

  Future<void> test_invalid_topLevel_nonClass() async {
    final content = '''
int? a^;
''';

    addTestSource(content);
    await expectNoTarget();
  }

  Future<void> test_invalid_topLevel_whitespace() async {
    final content = '''
int? a;
^
int? b;
''';

    addTestSource(content);
    await expectNoTarget();
  }

  Future<void> test_mixin_body() async {
    final content = '''
/*[0*/mixin /*[1*/MyMixin1/*1]*/ {
  ^
}/*0]*/
    ''';

    addTestSource(content);
    await expectTarget(
      _isItem(
        'MyMixin1',
        testFile,
        codeRange: code.ranges[0].sourceRange,
        nameRange: code.ranges[1].sourceRange,
      ),
    );
  }

  Future<void> test_mixin_keyword() async {
    final content = '''
/*[0*/mi^xin /*[1*/MyMixin1/*1]*/ {
}/*0]*/
    ''';

    addTestSource(content);
    await expectTarget(
      _isItem(
        'MyMixin1',
        testFile,
        codeRange: code.ranges[0].sourceRange,
        nameRange: code.ranges[1].sourceRange,
      ),
    );
  }

  Future<void> test_mixinName() async {
    final content = '''
/*[0*/mixin /*[1*/MyMix^in1/*1]*/ {
}/*0]*/
    ''';

    addTestSource(content);
    await expectTarget(
      _isItem(
        'MyMixin1',
        testFile,
        codeRange: code.ranges[0].sourceRange,
        nameRange: code.ranges[1].sourceRange,
      ),
    );
  }
}
