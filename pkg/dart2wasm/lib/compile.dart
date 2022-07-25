// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:typed_data';

import 'package:front_end/src/api_unstable/vm.dart'
    show
        CompilerOptions,
        CompilerResult,
        DiagnosticMessage,
        kernelForProgram,
        NnbdMode,
        Severity;

import 'package:kernel/ast.dart';
import 'package:kernel/core_types.dart';
import 'package:kernel/target/targets.dart';
import 'package:kernel/type_environment.dart';
import 'package:kernel/verifier.dart';

import 'package:vm/transformations/type_flow/transformer.dart' as globalTypeFlow
    show transformComponent;

import 'package:dart2wasm/compiler_options.dart' as compiler;
import 'package:dart2wasm/target.dart';
import 'package:dart2wasm/translator.dart';

/// Compile a Dart file into a Wasm module.
///
/// Returns `null` if an error occurred during compilation. The
/// [handleDiagnosticMessage] callback will have received an error message
/// describing the error.
Future<Uint8List?> compileToModule(compiler.CompilerOptions options,
    void Function(DiagnosticMessage) handleDiagnosticMessage) async {
  var succeeded = true;
  void diagnosticMessageHandler(DiagnosticMessage message) {
    if (message.severity == Severity.error) {
      succeeded = false;
    }
    handleDiagnosticMessage(message);
  }

  Target target = WasmTarget();
  CompilerOptions compilerOptions = CompilerOptions()
    ..target = target
    ..sdkRoot = options.sdkPath
    ..environmentDefines = {}
    ..verbose = false
    ..onDiagnostic = diagnosticMessageHandler
    ..nnbdMode = NnbdMode.Strong;

  if (options.platformPath != null) {
    compilerOptions.sdkSummary = options.platformPath;
  } else {
    compilerOptions.compileSdk = true;
  }

  CompilerResult? compilerResult =
      await kernelForProgram(options.mainUri, compilerOptions);
  if (compilerResult == null || !succeeded) {
    return null;
  }
  Component component = compilerResult.component!;
  CoreTypes coreTypes = compilerResult.coreTypes!;

  globalTypeFlow.transformComponent(target, coreTypes, component,
      treeShakeSignatures: true,
      treeShakeWriteOnlyFields: true,
      useRapidTypeAnalysis: false);

  assert(() {
    verifyComponent(component,
        afterConst: true, constantsAreAlwaysInlined: true);
    return true;
  }());

  var translator = Translator(
      component,
      coreTypes,
      TypeEnvironment(coreTypes, compilerResult.classHierarchy!),
      options.translatorOptions);
  return translator.translate();
}
