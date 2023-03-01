// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// TODO(51557): Decide if the mixins being applied in this test should be
// "mixin", "mixin class" or the test should be left at 2.19.
// @dart=2.19

// Dart test for testing access to private fields on mixins.

library private_mixin2;

import 'package:expect/expect.dart';
import 'other_mixin2.dart';

void main() {
  var c1;
  c1 = new C1();
  Expect.throwsNoSuchMethodError(() => c1._field);
  Expect.throwsNoSuchMethodError(() => c1.field);

  var c2;
  c2 = new C2();
  Expect.throwsNoSuchMethodError(() => c2._field);
  Expect.equals(42, c2.field);
}
