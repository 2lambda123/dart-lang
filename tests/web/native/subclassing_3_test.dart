// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'native_testing.dart';
import 'dart:_js_helper' show setNativeSubclassDispatchRecord;
import 'dart:_interceptors' show Interceptor, findInterceptorForType;

// Test calling convention of methods introduced on subclasses of native
// class of mixin.

doFoo(r, x) => '$x,${r.oof()},${r.miz()}';

mixin M {
  miz() => 'M';
}

@Native("N")
class N {
  foo(x) => (doFoo)(this, x);
}

class A extends N {}

class B extends A with M {
  // [oof] is introduced only on this subclass of a native class.  It should
  // have interceptor calling convention.
  oof() => 'B';
  // [miz] is introduced only on the mixin-application A+M.
}

B makeB() native;

@Creates('=Object')
getBPrototype() native;

void setup() {
  JS('', r"""
(function(){
  function B() {}
  self.makeB = function(){return new B();};

  self.getBPrototype = function(){return B.prototype;};
})()""");
}

main() {
  nativeTesting();
  setup();

  setNativeSubclassDispatchRecord(getBPrototype(), findInterceptorForType(B));

  B b = makeB();
  Expect.equals('1,B,M', b.foo(1));
}
