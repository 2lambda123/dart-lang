// Copyright (c) 2018, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

void voidValue = null;

void main() {
  test();
}

// Testing that a block bodied function may not return void
Future<FutureOr<void>> test() {
  return voidValue;
  //     ^^^^^^^^^
  // [analyzer] COMPILE_TIME_ERROR.RETURN_OF_INVALID_TYPE
  // [cfe] A value of type 'void' can't be returned from a function with return type 'Future<FutureOr<void>>'.
}
