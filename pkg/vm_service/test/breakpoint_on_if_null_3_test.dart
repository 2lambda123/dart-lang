// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library breakpoint_in_parts_class;

import 'common/service_test_common.dart';
import 'common/test_helper.dart';

const int LINE = 17;
const String file = 'breakpoint_on_if_null_3_test.dart';

void code() {
  foo(42);
}

void foo(dynamic args) {
  if (args == null) {
    print('was null');
  }
  if (args != null) {
    print('was not null');
  }
  if (args == 42) {
    print('was 42!');
  }
}

final stops = <String>[];

const expected = <String>[
  '$file:${LINE + 0}:18', // on 'args'
  '$file:${LINE + 1}:12', // on '=='
  '$file:${LINE + 4}:12', // on '!='
  '$file:${LINE + 5}:5', // on 'print'
  '$file:${LINE + 7}:12', // on '=='
  '$file:${LINE + 8}:5', // on 'print'
  '$file:${LINE + 10}:1', // on ending '}'
];

final tests = <IsolateTest>[
  hasPausedAtStart,
  setBreakpointAtUriAndLine(file, LINE),
  runStepThroughProgramRecordingStops(stops),
  checkRecordedStops(stops, expected),
];

void main([args = const <String>[]]) => runIsolateTests(
      args,
      tests,
      'breakpoint_on_if_null_3_test.dart',
      testeeConcurrent: code,
      pauseOnStart: true,
      pauseOnExit: true,
    );
