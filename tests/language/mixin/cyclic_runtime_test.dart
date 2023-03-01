// TODO(multitest): This was automatically migrated from a multitest and may
// contain strange or dead code.

// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// TODO(51557): Decide if the mixins being applied in this test should be
// "mixin", "mixin class" or the test should be left at 2.19.
// @dart=2.19

// Test for cyclicity check on named mixin applications.

class A<T> {}

class S {}

class M<T> {}

class C1 = S with M;

class C3 = S with M implements A;


void main() {
  new C1();

  new C3();

}
