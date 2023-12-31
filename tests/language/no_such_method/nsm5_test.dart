// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Test for compile-time errors for member access on classes that inherit a
// user defined noSuchMethod, even if it is abstract.

import 'package:expect/expect.dart';

abstract class Mock {
  noSuchMethod(i);
}

abstract class Foo {
  int foo();
}

class WarnMe extends Mock implements Foo {}
//    ^^^^^^
// [analyzer] COMPILE_TIME_ERROR.NON_ABSTRACT_CLASS_INHERITS_ABSTRACT_MEMBER
// [cfe] The non-abstract class 'WarnMe' is missing implementations for these members:

main() {}
