// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// @dart=2.19

class A<T> {}

class B<S> {
  int? foo(S s) => null;
}

class C extends A<int> with B<String> {}

main() {
  var list = <String>['foo'];
  var c = new C();
  list.map(c.foo);
}
