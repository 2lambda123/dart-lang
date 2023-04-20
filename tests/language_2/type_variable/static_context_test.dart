// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// @dart = 2.9

// A type variable can't be referenced in a static class

class A<T> {
  static int method() {
    // error, can't reference a type variable in a static context
    var foo = new T();
    //            ^
    // [analyzer] COMPILE_TIME_ERROR.CREATION_WITH_NON_TYPE
    // [analyzer] COMPILE_TIME_ERROR.TYPE_PARAMETER_REFERENCED_BY_STATIC
    // [cfe] Couldn't find constructor 'T'.
  }
}

main() {
  A.method();
}
