// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// @dart=2.19

class C<T> extends Object
  with Malformed // //# 01: compile-time error
  with T //         //# 02: compile-time error
  with T<int> //    //# 03: compile-time error
{}

main() => new C<C>();
