// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

@JS()
library developer_events_test;

import 'dart:developer'
    show postEvent, registerExtension, ServiceExtensionResponse;
import 'dart:convert';

import 'package:js/js.dart';
import 'package:expect/expect.dart';
import 'package:expect/minitest.dart';

@JS(r'$emitDebugEvent')
external set emitDebugEvent(void Function(String, String)? func);

@JS(r'$emitDebugEvent')
external void Function(String, String)? get emitDebugEvent;

@JS(r'$emitRegisterEvent')
external set emitRegisterEvent(void Function(String)? func);

@JS(r'$emitRegisterEvent')
external void Function(String)? get emitRegisterEvent;

@JS(r'console.warn')
external set consoleWarn(void Function(String) func);

@JS(r'console.warn')
external void Function(String) get consoleWarn;

@JS(r'console.debug')
external set consoleDebug(void Function(String) func);

@JS(r'console.debug')
external void Function(String) get consoleDebug;

@JS(r'$dwdsVersion')
external set dwdsVersion(String? s);

@JS(r'$dwdsVersion')
external String? get dwdsVersion;

class _TestDebugEvent {
  final String kind;
  final String eventData;
  _TestDebugEvent(this.kind, this.eventData);
}

void main() {
  testBackwardsCompatibility();
  testWarningMessages();
  testPostEvent();
  testRegisterExtension();
}

/// Verify backwards compatibility for sending messages on the console.debug log
/// in the chrome browser when the hooks have not been set.
// TODO(nshahan) Remove testing of debug log after package:dwds removes support.
// https://github.com/dart-lang/webdev/issues/1342`
void testBackwardsCompatibility() {
  var consoleDebugLog = <List>[];
  var savedConsoleDebug = consoleDebug;
  var savedDwdsVersion = dwdsVersion;

  try {
    // Patch our own console.debug function for testing.
    consoleDebug = allowInterop((arg1, [arg2, arg3]) => consoleDebugLog.add([
          arg1,
          if (arg2 != null) arg2,
          if (arg3 != null) arg3,
        ]));
    // Provide a version to signal there is an attached debugger.
    dwdsVersion = '1.0.0-for-test';

    // All post and register events should go to the console debug log.
    var data0 = {'key0': 'value0'};
    postEvent('kind0', data0);

    expect(consoleDebugLog.single[0], 'dart.developer.postEvent');
    expect(consoleDebugLog.single[1], 'kind0');
    Expect.contains('"key0":"value0"', consoleDebugLog.single[2]);

    var testHandler = (String s, Map<String, String> m) async =>
        ServiceExtensionResponse.result('test result');

    registerExtension('ext.method0', testHandler);
    expect(consoleDebugLog.length, 2);
    expect(consoleDebugLog[1].first, 'dart.developer.registerExtension');
    expect(consoleDebugLog[1].last, 'ext.method0');

    var data1 = {'key1': 'value1'};
    postEvent('kind1', data1);

    expect(consoleDebugLog.length, 3);
    expect(consoleDebugLog[2][0], 'dart.developer.postEvent');
    expect(consoleDebugLog[2][1], 'kind1');
    Expect.contains('"key1":"value1"', consoleDebugLog[2][2]);

    registerExtension('ext.method1', testHandler);
    expect(consoleDebugLog.length, 4);
    expect(consoleDebugLog[3].first, 'dart.developer.registerExtension');
    expect(consoleDebugLog[3].last, 'ext.method1');
  } finally {
    // Restore actual console.debug function.
    consoleDebug = savedConsoleDebug;
    dwdsVersion = savedDwdsVersion;
  }
}

/// Verify that warning messages are printed on the first call of postEvent()
/// and registerExtension() when the hooks are undefined.
void testWarningMessages() {
  final consoleWarnLog = <String>[];
  var savedConsoleWarn = consoleWarn;
  try {
    // Patch our own console.warn function for testing.
    consoleWarn = allowInterop((String s) => consoleWarnLog.add(s));
    expect(consoleWarnLog.isEmpty, true);

    var data0 = {'key0': 'value0'};
    postEvent('kind0', data0);

    // Nothing is listening, so this was a no-op.
    expect(consoleWarnLog.isEmpty, true);

    postEvent('kind0', data0);
    var data1 = {'key1': 'value1'};
    postEvent('kind1', data1);

    // No warnings should be issued because postEvent is a no-op.
    expect(consoleWarnLog.length, 0);

    consoleWarnLog.clear();

    var testHandler = (String s, Map<String, String> m) async =>
        ServiceExtensionResponse.result('test result');

    expect(consoleWarnLog.isEmpty, true);

    registerExtension('ext.method0', testHandler);

    // A warning message was issued about calling `registerExtension()` from
    // dart:developer.
    expect(
        consoleWarnLog.single
            .contains('registerExtension() from dart:developer'),
        true);

    registerExtension('ext.method1', testHandler);
    registerExtension('ext.method2', testHandler);

    // A warning is only issued on the first call of `registerExtension()`.
    expect(consoleWarnLog.length, 1);
  } finally {
    // Restore actual console.warn function.
    consoleWarn = savedConsoleWarn;
  }
}

void testPostEvent() {
  final debugEventLog = <_TestDebugEvent>[];
  var savedEmitDebugEvent = emitDebugEvent;
  var savedDwdsVersion = dwdsVersion;

  try {
    // Provide a test version of the $emitDebugEvent hook.
    emitDebugEvent = allowInterop((String kind, String eventData) {
      debugEventLog.add(_TestDebugEvent(kind, eventData));
    });
    // Provide a version to signal there is an attached debugger.
    dwdsVersion = '1.0.0-for-test';
    expect(debugEventLog.isEmpty, true);

    var data0 = {'key0': 'value0'};
    postEvent('kind0', data0);

    expect(debugEventLog.single.kind, 'kind0');
    Expect.contains('"key0":"value0"', debugEventLog.single.eventData);

    var data1 = {'key1': 'value1'};
    var data2 = {'key2': 'value2'};
    postEvent('kind1', data1);
    postEvent('kind2', data2);

    expect(debugEventLog.length, 3);
    expect(debugEventLog[0].kind, 'kind0');
    Expect.contains('"key0":"value0"', debugEventLog[0].eventData);
    expect(debugEventLog[1].kind, 'kind1');
    Expect.contains('"key1":"value1"', debugEventLog[1].eventData);
    expect(debugEventLog[2].kind, 'kind2');
    Expect.contains('"key2":"value2"', debugEventLog[2].eventData);
  } finally {
    emitDebugEvent = savedEmitDebugEvent;
    dwdsVersion = savedDwdsVersion;
  }
}

void testRegisterExtension() {
  final registerEventLog = <String>[];
  var savedEmitRegisterEvent = emitRegisterEvent;
  var savedDwdsVersion = dwdsVersion;

  try {
    // Provide a test version of the $emitRegisterEvent hook.
    emitRegisterEvent = allowInterop((String eventData) {
      registerEventLog.add(eventData);
    });
    // Provide a version to signal there is an attached debugger.
    dwdsVersion = '1.0.0-for-test';
    expect(registerEventLog.isEmpty, true);

    var testHandler = (String s, Map<String, String> m) async =>
        ServiceExtensionResponse.result('test result');
    registerExtension('ext.method0', testHandler);

    expect(registerEventLog.single, 'ext.method0');

    registerExtension('ext.method1', testHandler);
    registerExtension('ext.method2', testHandler);

    expect(registerEventLog.length, 3);
    expect(registerEventLog[0], 'ext.method0');
    expect(registerEventLog[1], 'ext.method1');
    expect(registerEventLog[2], 'ext.method2');
  } finally {
    emitRegisterEvent = savedEmitRegisterEvent;
    dwdsVersion = savedDwdsVersion;
  }
}
