// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
//
// SharedObjects=ffi_test_functions
//
// VMOptions=--optimization-counter-threshold=200

import 'dart:ffi';

import 'dylib_utils.dart';

final class MyStruct extends Struct {
  @Int8()
  external int a;
}

typedef _c_pass_struct = Int32 Function(Pointer<MyStruct>);

typedef _dart_pass_struct = int Function(Pointer<MyStruct>);

int pass_struct(Pointer<MyStruct> arg0) {
  _pass_struct ??= ffiTestFunctions
      .lookupFunction<_c_pass_struct, _dart_pass_struct>('PassStruct');
  return _pass_struct!.call(arg0);
}

_dart_pass_struct? _pass_struct;

final ffiTestFunctions = dlopenPlatformSpecific("ffi_test_functions");

void main() {
  for (int i = 0; i < 10000; i++) {
    pass_struct(nullptr);
  }
}
