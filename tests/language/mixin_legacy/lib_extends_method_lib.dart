// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// @dart=2.19

library mixin_lib_extends_method_lib;

mixin M1 {
  bar() => "M1-bar";

  clo(s) {
    var l = s;
    return (s) => "$l$s";
  }
}

mixin M2 {
  // Make sure mixed-in method has access to library-private names.
  bar() => _M2_bar();
  baz() => _M2_baz;
  fez() => "M2-${_fez()}";
  _fez() => "fez";
}

_M2_bar() {
  return "M2-bar";
}

var _M2_baz = "M2-baz";
