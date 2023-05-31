// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

class A {}

Future<void> h1<X extends Future<A>?>(X x) async {
  var x2 = await x; // Remains null.
  print([x2].runtimeType); // 'List<A>`.
  print(x2); // 'null': A soundness violation.
}

void main() async => await h1<Null>(null);
