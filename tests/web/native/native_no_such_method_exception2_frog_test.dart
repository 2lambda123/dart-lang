// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import "native_testing.dart";

@Native("A")
class A {}

@Native("B")
class B extends A {
  foo() native;
}

makeA() native;
makeB() native;

setup() {
  JS('', r"""
(function(){
  function inherits(child, parent) {
    if (Object.getPrototypeOf(child.prototype)) {
      Object.setPrototypeOf(child.prototype, parent.prototype);
    } else {
      function tmp() {};
      tmp.prototype = parent.prototype;
      child.prototype = new tmp();
      child.prototype.constructor = child;
    }
  }
    function A() {}
    function B() {}
    inherits(B, A);
    self.makeA = function() { return new A() };
    self.makeB = function() { return new B() };
    B.prototype.foo = function() { return 42; };

    self.nativeConstructor(A);
    self.nativeConstructor(B);
})()""");
  applyTestExtensions(['A', 'B']);
}

main() {
  nativeTesting();
  setup();
  var a = makeA();
  var exception;
  try {
    a.foo();
  } on NoSuchMethodError catch (e) {
    exception = e;
  }
  Expect.isNotNull(exception);

  var b = makeB();
  Expect.equals(42, b.foo());
}
