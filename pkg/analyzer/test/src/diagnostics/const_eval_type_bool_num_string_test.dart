// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/src/error/codes.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../dart/resolution/context_collection_resolution.dart';

main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(ConstEvalTypeBoolNumStringTest);
  });
}

@reflectiveTest
class ConstEvalTypeBoolNumStringTest extends PubPackageResolutionTest {
  test_equal_double_object() async {
    await assertNoErrorsInCode(r'''
const a = 0.1;
const b = a == Object();
''');
  }

  test_equal_int_object() async {
    await assertNoErrorsInCode(r'''
const a = 0;
const b = a == Object();
''');
  }

  test_equal_int_userClass() async {
    await assertNoErrorsInCode(r'''
class A {
  const A();
}

const a = 0;
const b = a == A();
''');
  }

  test_equal_null_object() async {
    await assertNoErrorsInCode(r'''
const a = null;
const b = a == Object();
''');
  }

  test_equal_string_object() async {
    await assertNoErrorsInCode(r'''
const a = 'foo';
const b = a == Object();
''');
  }

  test_equal_userClass_int() async {
    await assertErrorsInCode(r'''
class A {
  const A();
}

const a = A();
const b = a == 0;
''', [
      error(CompileTimeErrorCode.CONST_EVAL_TYPE_BOOL_NUM_STRING, 51, 6),
    ]);
  }

  test_notEqual_double_object() async {
    await assertNoErrorsInCode(r'''
const a = 0.1;
const b = a != Object();
''');
  }

  test_notEqual_int_object() async {
    await assertNoErrorsInCode(r'''
const a = 0;
const b = a != Object();
''');
  }

  test_notEqual_int_userClass() async {
    await assertNoErrorsInCode(r'''
class A {
  const A();
}

const a = 0;
const b = a != A();
''');
  }

  test_notEqual_null_object() async {
    await assertNoErrorsInCode(r'''
const a = null;
const b = a != Object();
''');
  }

  test_notEqual_string_object() async {
    await assertNoErrorsInCode(r'''
const a = 'foo';
const b = a != Object();
''');
  }

  test_notEqual_userClass_int() async {
    await assertErrorsInCode(r'''
class A {
  const A();
}

const a = A();
const b = a != 0;
''', [
      error(CompileTimeErrorCode.CONST_EVAL_TYPE_BOOL_NUM_STRING, 51, 6),
    ]);
  }
}
