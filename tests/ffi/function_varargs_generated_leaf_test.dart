// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
//
// This file has been automatically generated. Please do not edit it manually.
// Generated by tests/ffi/generator/structs_by_value_tests_generator.dart.
//
// SharedObjects=ffi_test_functions
// VMOptions=--deterministic --optimization-counter-threshold=90
// VMOptions=--use-slow-path
// VMOptions=--use-slow-path --stacktrace-every=100

import 'dart:ffi';

import "package:expect/expect.dart";
import "package:ffi/ffi.dart";

import 'dylib_utils.dart';

// Reuse the compound classes.
import 'function_structs_by_value_generated_compounds.dart';

final ffiTestFunctions = dlopenPlatformSpecific("ffi_test_functions");
void main() {
  for (int i = 0; i < 100; ++i) {
    testVariadicAt1Int64x2Leaf();
    testVariadicAt1Doublex2Leaf();
    testVariadicAt1Int64x5Leaf();
    testVariadicAt1Doublex5Leaf();
    testVariadicAt1Int64x20Leaf();
    testVariadicAt1Doublex20Leaf();
    testVariadicAt1Int64x2Struct8BytesIntInt64Leaf();
    testVariadicAt1Doublex2Struct32BytesHomogeneousDoubleDLeaf();
    testVariadicAt1DoubleStruct12BytesHomogeneousFloatDoubLeaf();
    testVariadicAt1Int32Struct20BytesHomogeneousInt32Int32Leaf();
    testVariadicAt1DoubleStruct20BytesHomogeneousFloatDoubLeaf();
    testVariadicAt2Int32Int64IntPtrLeaf();
    testVariadicAt1DoubleInt64Int32DoubleInt64Int32Leaf();
    testVariadicAt1Int64Int32Struct12BytesHomogeneousFloatLeaf();
    testVariadicAt11Doublex8FloatStruct12BytesHomogeneousFLeaf();
    testVariadicAt1DoubleInt64Int32Struct20BytesHomogeneouLeaf();
    testVariadicAt5Doublex5Leaf();
  }
}

final variadicAt1Int64x2Leaf = ffiTestFunctions.lookupFunction<
    Int64 Function(Int64, VarArgs<(Int64,)>),
    int Function(int, int)>("VariadicAt1Int64x2", isLeaf: true);

/// Single variadic argument.
void testVariadicAt1Int64x2Leaf() {
  int a0;
  int a1;

  a0 = -1;
  a1 = 2;

  final result = variadicAt1Int64x2Leaf(a0, a1);

  print("result = $result");

  Expect.equals(1, result);
}

final variadicAt1Doublex2Leaf = ffiTestFunctions.lookupFunction<
    Double Function(Double, VarArgs<(Double,)>),
    double Function(double, double)>("VariadicAt1Doublex2", isLeaf: true);

/// Single variadic argument.
void testVariadicAt1Doublex2Leaf() {
  double a0;
  double a1;

  a0 = -1.0;
  a1 = 2.0;

  final result = variadicAt1Doublex2Leaf(a0, a1);

  print("result = $result");

  Expect.approxEquals(1.0, result);
}

final variadicAt1Int64x5Leaf = ffiTestFunctions.lookupFunction<
    Int64 Function(Int64, VarArgs<(Int64, Int64, Int64, Int64)>),
    int Function(int, int, int, int, int)>("VariadicAt1Int64x5", isLeaf: true);

/// Variadic arguments.
void testVariadicAt1Int64x5Leaf() {
  int a0;
  int a1;
  int a2;
  int a3;
  int a4;

  a0 = -1;
  a1 = 2;
  a2 = -3;
  a3 = 4;
  a4 = -5;

  final result = variadicAt1Int64x5Leaf(a0, a1, a2, a3, a4);

  print("result = $result");

  Expect.equals(-3, result);
}

final variadicAt1Doublex5Leaf = ffiTestFunctions.lookupFunction<
    Double Function(Double, VarArgs<(Double, Double, Double, Double)>),
    double Function(double, double, double, double,
        double)>("VariadicAt1Doublex5", isLeaf: true);

/// Variadic arguments.
void testVariadicAt1Doublex5Leaf() {
  double a0;
  double a1;
  double a2;
  double a3;
  double a4;

  a0 = -1.0;
  a1 = 2.0;
  a2 = -3.0;
  a3 = 4.0;
  a4 = -5.0;

  final result = variadicAt1Doublex5Leaf(a0, a1, a2, a3, a4);

  print("result = $result");

  Expect.approxEquals(-3.0, result);
}

final variadicAt1Int64x20Leaf = ffiTestFunctions.lookupFunction<
    Int64 Function(
        Int64,
        VarArgs<
            (
              Int64,
              Int64,
              Int64,
              Int64,
              Int64,
              Int64,
              Int64,
              Int64,
              Int64,
              Int64,
              Int64,
              Int64,
              Int64,
              Int64,
              Int64,
              Int64,
              Int64,
              Int64,
              Int64
            )>),
    int Function(
        int,
        int,
        int,
        int,
        int,
        int,
        int,
        int,
        int,
        int,
        int,
        int,
        int,
        int,
        int,
        int,
        int,
        int,
        int,
        int)>("VariadicAt1Int64x20", isLeaf: true);

/// Variadic arguments exhaust registers.
void testVariadicAt1Int64x20Leaf() {
  int a0;
  int a1;
  int a2;
  int a3;
  int a4;
  int a5;
  int a6;
  int a7;
  int a8;
  int a9;
  int a10;
  int a11;
  int a12;
  int a13;
  int a14;
  int a15;
  int a16;
  int a17;
  int a18;
  int a19;

  a0 = -1;
  a1 = 2;
  a2 = -3;
  a3 = 4;
  a4 = -5;
  a5 = 6;
  a6 = -7;
  a7 = 8;
  a8 = -9;
  a9 = 10;
  a10 = -11;
  a11 = 12;
  a12 = -13;
  a13 = 14;
  a14 = -15;
  a15 = 16;
  a16 = -17;
  a17 = 18;
  a18 = -19;
  a19 = 20;

  final result = variadicAt1Int64x20Leaf(a0, a1, a2, a3, a4, a5, a6, a7, a8, a9,
      a10, a11, a12, a13, a14, a15, a16, a17, a18, a19);

  print("result = $result");

  Expect.equals(10, result);
}

final variadicAt1Doublex20Leaf = ffiTestFunctions.lookupFunction<
    Double Function(
        Double,
        VarArgs<
            (
              Double,
              Double,
              Double,
              Double,
              Double,
              Double,
              Double,
              Double,
              Double,
              Double,
              Double,
              Double,
              Double,
              Double,
              Double,
              Double,
              Double,
              Double,
              Double
            )>),
    double Function(
        double,
        double,
        double,
        double,
        double,
        double,
        double,
        double,
        double,
        double,
        double,
        double,
        double,
        double,
        double,
        double,
        double,
        double,
        double,
        double)>("VariadicAt1Doublex20", isLeaf: true);

/// Variadic arguments exhaust registers.
void testVariadicAt1Doublex20Leaf() {
  double a0;
  double a1;
  double a2;
  double a3;
  double a4;
  double a5;
  double a6;
  double a7;
  double a8;
  double a9;
  double a10;
  double a11;
  double a12;
  double a13;
  double a14;
  double a15;
  double a16;
  double a17;
  double a18;
  double a19;

  a0 = -1.0;
  a1 = 2.0;
  a2 = -3.0;
  a3 = 4.0;
  a4 = -5.0;
  a5 = 6.0;
  a6 = -7.0;
  a7 = 8.0;
  a8 = -9.0;
  a9 = 10.0;
  a10 = -11.0;
  a11 = 12.0;
  a12 = -13.0;
  a13 = 14.0;
  a14 = -15.0;
  a15 = 16.0;
  a16 = -17.0;
  a17 = 18.0;
  a18 = -19.0;
  a19 = 20.0;

  final result = variadicAt1Doublex20Leaf(a0, a1, a2, a3, a4, a5, a6, a7, a8,
      a9, a10, a11, a12, a13, a14, a15, a16, a17, a18, a19);

  print("result = $result");

  Expect.approxEquals(10.0, result);
}

final variadicAt1Int64x2Struct8BytesIntInt64Leaf =
    ffiTestFunctions.lookupFunction<
        Int64 Function(Int64, VarArgs<(Int64, Struct8BytesInt, Int64)>),
        int Function(int, int, Struct8BytesInt,
            int)>("VariadicAt1Int64x2Struct8BytesIntInt64", isLeaf: true);

/// Variadic arguments including struct.
void testVariadicAt1Int64x2Struct8BytesIntInt64Leaf() {
  int a0;
  int a1;
  final a2Pointer = calloc<Struct8BytesInt>();
  final Struct8BytesInt a2 = a2Pointer.ref;
  int a3;

  a0 = -1;
  a1 = 2;
  a2.a0 = -3;
  a2.a1 = 4;
  a2.a2 = -5;
  a3 = 6;

  final result = variadicAt1Int64x2Struct8BytesIntInt64Leaf(a0, a1, a2, a3);

  print("result = $result");

  Expect.equals(3, result);

  calloc.free(a2Pointer);
}

final variadicAt1Doublex2Struct32BytesHomogeneousDoubleDLeaf = ffiTestFunctions
    .lookupFunction<
            Double Function(Double,
                VarArgs<(Double, Struct32BytesHomogeneousDouble, Double)>),
            double Function(
                double, double, Struct32BytesHomogeneousDouble, double)>(
        "VariadicAt1Doublex2Struct32BytesHomogeneousDoubleD",
        isLeaf: true);

/// Variadic arguments including struct.
void testVariadicAt1Doublex2Struct32BytesHomogeneousDoubleDLeaf() {
  double a0;
  double a1;
  final a2Pointer = calloc<Struct32BytesHomogeneousDouble>();
  final Struct32BytesHomogeneousDouble a2 = a2Pointer.ref;
  double a3;

  a0 = -1.0;
  a1 = 2.0;
  a2.a0 = -3.0;
  a2.a1 = 4.0;
  a2.a2 = -5.0;
  a2.a3 = 6.0;
  a3 = -7.0;

  final result =
      variadicAt1Doublex2Struct32BytesHomogeneousDoubleDLeaf(a0, a1, a2, a3);

  print("result = $result");

  Expect.approxEquals(-4.0, result);

  calloc.free(a2Pointer);
}

final variadicAt1DoubleStruct12BytesHomogeneousFloatDoubLeaf =
    ffiTestFunctions.lookupFunction<
            Double Function(
                Double, VarArgs<(Struct12BytesHomogeneousFloat, Double)>),
            double Function(double, Struct12BytesHomogeneousFloat, double)>(
        "VariadicAt1DoubleStruct12BytesHomogeneousFloatDoub",
        isLeaf: true);

/// Variadic arguments including struct.
void testVariadicAt1DoubleStruct12BytesHomogeneousFloatDoubLeaf() {
  double a0;
  final a1Pointer = calloc<Struct12BytesHomogeneousFloat>();
  final Struct12BytesHomogeneousFloat a1 = a1Pointer.ref;
  double a2;

  a0 = -1.0;
  a1.a0 = 2.0;
  a1.a1 = -3.0;
  a1.a2 = 4.0;
  a2 = -5.0;

  final result =
      variadicAt1DoubleStruct12BytesHomogeneousFloatDoubLeaf(a0, a1, a2);

  print("result = $result");

  Expect.approxEquals(-3.0, result);

  calloc.free(a1Pointer);
}

final variadicAt1Int32Struct20BytesHomogeneousInt32Int32Leaf =
    ffiTestFunctions
        .lookupFunction<
                Int32 Function(
                    Int32, VarArgs<(Struct20BytesHomogeneousInt32, Int32)>),
                int Function(int, Struct20BytesHomogeneousInt32, int)>(
            "VariadicAt1Int32Struct20BytesHomogeneousInt32Int32",
            isLeaf: true);

/// Variadic arguments including struct.
void testVariadicAt1Int32Struct20BytesHomogeneousInt32Int32Leaf() {
  int a0;
  final a1Pointer = calloc<Struct20BytesHomogeneousInt32>();
  final Struct20BytesHomogeneousInt32 a1 = a1Pointer.ref;
  int a2;

  a0 = -1;
  a1.a0 = 2;
  a1.a1 = -3;
  a1.a2 = 4;
  a1.a3 = -5;
  a1.a4 = 6;
  a2 = -7;

  final result =
      variadicAt1Int32Struct20BytesHomogeneousInt32Int32Leaf(a0, a1, a2);

  print("result = $result");

  Expect.equals(-4, result);

  calloc.free(a1Pointer);
}

final variadicAt1DoubleStruct20BytesHomogeneousFloatDoubLeaf =
    ffiTestFunctions.lookupFunction<
            Double Function(
                Double, VarArgs<(Struct20BytesHomogeneousFloat, Double)>),
            double Function(double, Struct20BytesHomogeneousFloat, double)>(
        "VariadicAt1DoubleStruct20BytesHomogeneousFloatDoub",
        isLeaf: true);

/// Variadic arguments including struct.
void testVariadicAt1DoubleStruct20BytesHomogeneousFloatDoubLeaf() {
  double a0;
  final a1Pointer = calloc<Struct20BytesHomogeneousFloat>();
  final Struct20BytesHomogeneousFloat a1 = a1Pointer.ref;
  double a2;

  a0 = -1.0;
  a1.a0 = 2.0;
  a1.a1 = -3.0;
  a1.a2 = 4.0;
  a1.a3 = -5.0;
  a1.a4 = 6.0;
  a2 = -7.0;

  final result =
      variadicAt1DoubleStruct20BytesHomogeneousFloatDoubLeaf(a0, a1, a2);

  print("result = $result");

  Expect.approxEquals(-4.0, result);

  calloc.free(a1Pointer);
}

final variadicAt2Int32Int64IntPtrLeaf = ffiTestFunctions.lookupFunction<
    Int32 Function(Int32, Int64, VarArgs<(IntPtr,)>),
    int Function(int, int, int)>("VariadicAt2Int32Int64IntPtr", isLeaf: true);

/// Regression test for variadic arguments.
/// https://github.com/dart-lang/sdk/issues/49460
void testVariadicAt2Int32Int64IntPtrLeaf() {
  int a0;
  int a1;
  int a2;

  a0 = -1;
  a1 = 2;
  a2 = -3;

  final result = variadicAt2Int32Int64IntPtrLeaf(a0, a1, a2);

  print("result = $result");

  Expect.equals(-2, result);
}

final variadicAt1DoubleInt64Int32DoubleInt64Int32Leaf =
    ffiTestFunctions.lookupFunction<
        Double Function(Double, VarArgs<(Int64, Int32, Double, Int64, Int32)>),
        double Function(double, int, int, double, int,
            int)>("VariadicAt1DoubleInt64Int32DoubleInt64Int32", isLeaf: true);

/// Variadic arguments mixed.
void testVariadicAt1DoubleInt64Int32DoubleInt64Int32Leaf() {
  double a0;
  int a1;
  int a2;
  double a3;
  int a4;
  int a5;

  a0 = -1.0;
  a1 = 2;
  a2 = -3;
  a3 = 4.0;
  a4 = -5;
  a5 = 6;

  final result =
      variadicAt1DoubleInt64Int32DoubleInt64Int32Leaf(a0, a1, a2, a3, a4, a5);

  print("result = $result");

  Expect.approxEquals(3.0, result);
}

final variadicAt1Int64Int32Struct12BytesHomogeneousFloatLeaf =
    ffiTestFunctions
        .lookupFunction<
                Double Function(
                    Int64, VarArgs<(Int32, Struct12BytesHomogeneousFloat)>),
                double Function(int, int, Struct12BytesHomogeneousFloat)>(
            "VariadicAt1Int64Int32Struct12BytesHomogeneousFloat",
            isLeaf: true);

/// Variadic arguments homogenous struct stack alignment on macos_arm64.
void testVariadicAt1Int64Int32Struct12BytesHomogeneousFloatLeaf() {
  int a0;
  int a1;
  final a2Pointer = calloc<Struct12BytesHomogeneousFloat>();
  final Struct12BytesHomogeneousFloat a2 = a2Pointer.ref;

  a0 = -1;
  a1 = 2;
  a2.a0 = -3.0;
  a2.a1 = 4.0;
  a2.a2 = -5.0;

  final result =
      variadicAt1Int64Int32Struct12BytesHomogeneousFloatLeaf(a0, a1, a2);

  print("result = $result");

  Expect.approxEquals(-3.0, result);

  calloc.free(a2Pointer);
}

final variadicAt11Doublex8FloatStruct12BytesHomogeneousFLeaf =
    ffiTestFunctions.lookupFunction<
            Double Function(
                Double,
                Double,
                Double,
                Double,
                Double,
                Double,
                Double,
                Double,
                Float,
                Struct12BytesHomogeneousFloat,
                Int64,
                VarArgs<(Int32, Struct12BytesHomogeneousFloat)>),
            double Function(
                double,
                double,
                double,
                double,
                double,
                double,
                double,
                double,
                double,
                Struct12BytesHomogeneousFloat,
                int,
                int,
                Struct12BytesHomogeneousFloat)>(
        "VariadicAt11Doublex8FloatStruct12BytesHomogeneousF",
        isLeaf: true);

/// Variadic arguments homogenous struct stack alignment on macos_arm64.
void testVariadicAt11Doublex8FloatStruct12BytesHomogeneousFLeaf() {
  double a0;
  double a1;
  double a2;
  double a3;
  double a4;
  double a5;
  double a6;
  double a7;
  double a8;
  final a9Pointer = calloc<Struct12BytesHomogeneousFloat>();
  final Struct12BytesHomogeneousFloat a9 = a9Pointer.ref;
  int a10;
  int a11;
  final a12Pointer = calloc<Struct12BytesHomogeneousFloat>();
  final Struct12BytesHomogeneousFloat a12 = a12Pointer.ref;

  a0 = -1.0;
  a1 = 2.0;
  a2 = -3.0;
  a3 = 4.0;
  a4 = -5.0;
  a5 = 6.0;
  a6 = -7.0;
  a7 = 8.0;
  a8 = -9.0;
  a9.a0 = 10.0;
  a9.a1 = -11.0;
  a9.a2 = 12.0;
  a10 = -13;
  a11 = 14;
  a12.a0 = -15.0;
  a12.a1 = 16.0;
  a12.a2 = -17.0;

  final result = variadicAt11Doublex8FloatStruct12BytesHomogeneousFLeaf(
      a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12);

  print("result = $result");

  Expect.approxEquals(-9.0, result);

  calloc.free(a9Pointer);
  calloc.free(a12Pointer);
}

final variadicAt1DoubleInt64Int32Struct20BytesHomogeneouLeaf =
    ffiTestFunctions.lookupFunction<
            Double Function(
                Double,
                VarArgs<
                    (
                      Int64,
                      Int32,
                      Struct20BytesHomogeneousInt32,
                      Double,
                      Int64,
                      Int32,
                      Struct12BytesHomogeneousFloat,
                      Int64
                    )>),
            double Function(
                double,
                int,
                int,
                Struct20BytesHomogeneousInt32,
                double,
                int,
                int,
                Struct12BytesHomogeneousFloat,
                int)>("VariadicAt1DoubleInt64Int32Struct20BytesHomogeneou",
        isLeaf: true);

/// Variadic arguments mixed.
void testVariadicAt1DoubleInt64Int32Struct20BytesHomogeneouLeaf() {
  double a0;
  int a1;
  int a2;
  final a3Pointer = calloc<Struct20BytesHomogeneousInt32>();
  final Struct20BytesHomogeneousInt32 a3 = a3Pointer.ref;
  double a4;
  int a5;
  int a6;
  final a7Pointer = calloc<Struct12BytesHomogeneousFloat>();
  final Struct12BytesHomogeneousFloat a7 = a7Pointer.ref;
  int a8;

  a0 = -1.0;
  a1 = 2;
  a2 = -3;
  a3.a0 = 4;
  a3.a1 = -5;
  a3.a2 = 6;
  a3.a3 = -7;
  a3.a4 = 8;
  a4 = -9.0;
  a5 = 10;
  a6 = -11;
  a7.a0 = 12.0;
  a7.a1 = -13.0;
  a7.a2 = 14.0;
  a8 = -15;

  final result = variadicAt1DoubleInt64Int32Struct20BytesHomogeneouLeaf(
      a0, a1, a2, a3, a4, a5, a6, a7, a8);

  print("result = $result");

  Expect.approxEquals(-8.0, result);

  calloc.free(a3Pointer);
  calloc.free(a7Pointer);
}

final variadicAt5Doublex5Leaf = ffiTestFunctions.lookupFunction<
    Double Function(Double, Double, Double, Double, Double, VarArgs<()>),
    double Function(double, double, double, double,
        double)>("VariadicAt5Doublex5", isLeaf: true);

/// Variadic arguments function definition, but not passing any.
void testVariadicAt5Doublex5Leaf() {
  double a0;
  double a1;
  double a2;
  double a3;
  double a4;

  a0 = -1.0;
  a1 = 2.0;
  a2 = -3.0;
  a3 = 4.0;
  a4 = -5.0;

  final result = variadicAt5Doublex5Leaf(a0, a1, a2, a3, a4);

  print("result = $result");

  Expect.approxEquals(-3.0, result);
}
