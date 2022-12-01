// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// SharedOptions=--enable-experiment=sealed-class

sealed class SealedClass {}

abstract class A extends SealedClass {}

class B extends SealedClass {}

sealed mixin SealedMixin {}

class C extends SealedClass with SealedMixin {}

class D with SealedMixin {}
