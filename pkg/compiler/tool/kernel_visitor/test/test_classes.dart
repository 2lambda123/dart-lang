// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
library info_visitor_test_classes;

// Test superclass value.
class A {
  A();

  getValue() {
    return "Value";
  }
}

// Test subclass calling "super".
class B extends A {
  B();

  testSuper() {
    return super.getValue();
  }
}

// Test subclass not calling "super".
class C extends B {
  C();

  @override
  getValue() {
    return "Value";
  }
}
