// Copyright (c) 2018, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// TODO(51557): Decide if the mixins being applied in this test should be
// "mixin", "mixin class" or the test should be left at 2.19.
// @dart=2.19

class Thing {}

class SubThing extends Thing {
  void sub() {}
}

class A {
  Thing get thing => new Thing();
}

abstract class B implements A {
  @override
  SubThing get thing;
}

class C extends A //
//    ^
// [analyzer] COMPILE_TIME_ERROR.INVALID_IMPLEMENTATION_OVERRIDE
// [cfe] The implementation of 'thing' in the non-abstract class 'C' does not conform to its interface.
    with
        B
{}

main() {
  new C()
          .thing //
          .sub()
      ;
}
