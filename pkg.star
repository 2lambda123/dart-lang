# Copyright (c) 2023 The Dart project authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.
"""
Defines the pkg builders.
"""

load("//lib/dart.star", "dart")
load(
    "//lib/defaults.star",
    "arm64",
    "chrome",
    "mac",
    "no_android",
    "windows",
)

dart.ci_sandbox_builder(
    "pkg-linux-release",
    category = "pkg|l",
    on_cq = True,
    properties = chrome,
)
dart.ci_sandbox_builder(
    "pkg-mac-release",
    category = "pkg|m",
    dimensions = mac,
    properties = chrome,
)
dart.ci_sandbox_builder(
    "pkg-mac-release-arm64",
    category = "pkg|m1",
    channels = ["try"],
    dimensions = [mac, arm64],
    properties = [chrome, no_android],
    experiments = {"dart.use_update_script": 100},
)
dart.ci_sandbox_builder(
    "pkg-win-release",
    category = "pkg|w",
    dimensions = windows,
    properties = chrome,
    experiments = {"dart.use_update_script": 100},
)
dart.ci_sandbox_builder(
    "pkg-linux-debug",
    category = "pkg|ld",
    channels = ["try"],
    properties = chrome,
)
