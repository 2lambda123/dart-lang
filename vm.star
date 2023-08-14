# Copyright (c) 2022 The Dart project authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.
"""
Defines the Dart VM builders.
"""

load("//lib/cron.star", "cron")
load("//lib/dart.star", "dart")
load(
    "//lib/defaults.star",
    "android_deps",
    "arm64",
    "flutter_pool",
    "focal",
    "fuchsia_deps",
    "mac",
    "no_android",
    "slow_shards",
    "windows",
    "windows11",
)
load("//lib/paths.star", "paths")
load("//lib/priority.star", "priority")

_postponed_alt_console_entries = []

dart.poller("dart-vm-gitiles-trigger", branches = ["main"], paths = paths.vm)
luci.notifier(
    name = "dart-vm-team",
    on_new_failure = True,
    notify_emails = ["dart-vm-team-breakages@google.com"],
)

def _builder(name, category = None, **kwargs):
    dart.ci_sandbox_builder(name, category = category, **kwargs)
    _postponed_alt_console_entry(name, category)

def _extra_builder(name, on_cq = False, location_filters = None, **kwargs):
    """
    Creates a Dart builder that is only triggered by VM commits.

    Args:
        name: The builder name.
        on_cq: Whether the build is added to the default set of CQ tryjobs.
        location_filters: Locations that trigger this builder.
        **kwargs: Extra arguments are passed on to dart_ci_sandbox_builder.
    """
    triggered_by = ["dart-vm-gitiles-trigger-%s"]
    if on_cq and not location_filters:
        # Don't add extra builders to the default CQ, trigger only on VM paths.
        location_filters = paths.to_location_filters(paths.vm)
        on_cq = False
    _builder(
        name,
        triggered_by = triggered_by,
        on_cq = on_cq,
        location_filters = location_filters,
        **kwargs
    )

def _low_priority_builder(name, **kwargs):
    _extra_builder(
        name,
        channels = ["try"],
        priority = priority.low,
        expiration_timeout = time.day,
        **kwargs
    )

def _nightly_builder(name, category, **kwargs):
    cron.nightly_builder(name, category = category, notifies = "dart-vm-team", **kwargs)
    _postponed_alt_console_entry(name, category)

def _postponed_alt_console_entry(name, category):
    if category:
        console_category, _, short_name = category.rpartition("|")
        _postponed_alt_console_entries.append({
            "builder": name,
            "category": console_category,
            "short_name": short_name,
        })

def add_postponed_alt_console_entries():
    for entry in _postponed_alt_console_entries:
        luci.console_view_entry(console_view = "alt", **entry)

# vm|jit
_extra_builder(
    "vm-linux-debug-x64",
    category = "vm|jit|d",
)
_extra_builder(
    "vm-linux-release-x64",
    category = "vm|jit|r",
)
_nightly_builder(
    "vm-linux-debug-ia32",
    category = "vm|jit|d3",
    channels = ["try"],
    properties = slow_shards,
)
_nightly_builder(
    "vm-linux-release-ia32",
    category = "vm|jit|r3",
    channels = ["try"],
)
_extra_builder(
    "vm-linux-release-simarm",
    category = "vm|jit|ra",
)
_extra_builder(
    "vm-linux-release-simarm64",
    category = "vm|jit|ra6",
)
_nightly_builder(
    "vm-linux-debug-simriscv64",
    category = "vm|jit|rv",
    channels = ["try"],
)
_extra_builder(
    "vm-linux-release-arm64",
    category = "vm|jit|a6",
    channels = [],
    execution_timeout = 4 * time.hour,
    properties = {"shard_timeout": (120 * time.minute) // time.second},
)
_extra_builder(
    "vm-mac-debug-arm64",
    category = "vm|jit|m1d",
    dimensions = [mac, arm64],
    properties = [no_android, slow_shards],
    on_cq = True,
)
_builder(
    "vm-mac-debug-x64",
    category = "vm|jit|md",
    dimensions = mac,
    properties = slow_shards,
)
_extra_builder(
    "vm-mac-release-arm64",
    category = "vm|jit|m1r",
    dimensions = [mac, arm64],
    properties = no_android,
    on_cq = True,
)
_extra_builder(
    "vm-checked-mac-release-arm64",
    category = "vm|jit|rc",
    dimensions = [mac, arm64],
    experiments = {"dart.use_update_script": 100},
)
_builder(
    "vm-mac-release-x64",
    category = "vm|jit|mr",
    dimensions = mac,
)
_nightly_builder(
    "vm-win-release-ia32",
    category = "vm|jit|wr3",
    channels = ["try"],
    dimensions = windows,
)
_builder(
    "vm-win-debug-x64",
    category = "vm|jit|wd",
    properties = slow_shards,
    dimensions = windows,
)
_builder(
    "vm-win-release-x64",
    category = "vm|jit|wr",
    dimensions = windows,
)
_extra_builder(
    "vm-win-debug-arm64",
    category = "vm|jit|wad",
    channels = ["try"],
    dimensions = [windows11, arm64, flutter_pool],
    goma = False,  # no such package: infra_internal/goma/client/windows-arm64
)
_extra_builder(
    "vm-win-release-arm64",
    category = "vm|jit|war",
    channels = ["try"],
    dimensions = [windows11, arm64, flutter_pool],
    goma = False,  # no such package: infra_internal/goma/client/windows-arm64
)

# vm|appjit
_extra_builder(
    "vm-appjit-linux-debug-x64",
    category = "vm|appjit|d",
    properties = slow_shards,
)
_extra_builder(
    "vm-appjit-linux-release-x64",
    category = "vm|appjit|r",
)
_nightly_builder(
    "vm-appjit-linux-product-x64",
    category = "vm|appjit|p",
    channels = ["try"],
)

# vm|aot
_extra_builder(
    "vm-aot-linux-release-x64",
    category = "vm|aot|r",
)
_extra_builder(
    "vm-aot-linux-debug-simarm_x64",
    category = "vm|aot|da",
    properties = slow_shards,
)
_extra_builder(
    "vm-aot-linux-release-simarm_x64",
    category = "vm|aot|ra",
)
_nightly_builder(
    "vm-aot-linux-debug-x64",
    category = "vm|aot|d",
    channels = ["try"],
    properties = slow_shards,
)
_extra_builder(
    "vm-aot-linux-release-simarm64",
    category = "vm|aot|ra6",
)
_nightly_builder(
    "vm-aot-linux-debug-simriscv64",
    category = "vm|aot|rv",
    channels = ["try"],
    properties = [slow_shards],
)
_nightly_builder(
    "vm-aot-linux-release-arm64",
    category = "vm|aot|a6",
    channels = [],
    properties = {"shard_timeout": (120 * time.minute) // time.second},
)
_extra_builder(
    "vm-aot-mac-release-arm64",
    category = "vm|aot|m1",
    channels = ["try"],
    dimensions = [mac, arm64],
    properties = [no_android, slow_shards],
)
_extra_builder(
    "vm-aot-mac-release-x64",
    category = "vm|aot|m",
    # The x64 Mac pool contains a mix of 4- and 8-core machines. This build
    # times out on a 4-core machine.
    dimensions = [mac, {"cores": "8"}],
    properties = slow_shards,
)
_extra_builder(
    "vm-aot-win-release-x64",
    category = "vm|aot|wr",
    dimensions = windows,
)
_extra_builder(
    "vm-aot-win-debug-arm64",
    category = "vm|aot|wad",
    channels = ["try"],
    dimensions = [windows11, arm64, flutter_pool],
    goma = False,  # no such package: infra_internal/goma/client/windows-arm64
)
_extra_builder(
    "vm-aot-win-release-arm64",
    category = "vm|aot|war",
    channels = ["try"],
    dimensions = [windows11, arm64, flutter_pool],
    goma = False,  # no such package: infra_internal/goma/client/windows-arm64
)

# vm|aot|android
_extra_builder(
    "vm-aot-android-release-arm_x64",
    category = "vm|aot|android|a32",
    properties = [android_deps, slow_shards],
)
_extra_builder(
    "vm-aot-android-release-arm64c",
    category = "vm|aot|android|a64",
    properties = [android_deps, slow_shards],
)

# vm|aot|product
_nightly_builder(
    "vm-aot-linux-product-x64",
    category = "vm|aot|product|l",
    channels = ["try"],
)
_nightly_builder(
    "vm-aot-mac-product-arm64",
    category = "vm|aot|product|m",
    channels = ["try"],
    dimensions = [mac, arm64],
)
_nightly_builder(
    "vm-aot-win-product-x64",
    category = "vm|aot|product|w",
    channels = ["try"],
    dimensions = windows,
)

# vm|aot
_nightly_builder(
    "vm-aot-obfuscate-linux-release-x64",
    category = "vm|aot|o",
    channels = ["try"],
)
_nightly_builder(
    "vm-aot-dwarf-linux-product-x64",
    category = "vm|aot|dw",
    channels = ["try"],
)

# vm|misc
_nightly_builder(
    "vm-eager-optimization-linux-release-ia32",
    category = "vm|misc|o32",
    channels = ["try"],
)
_low_priority_builder(
    "vm-eager-optimization-linux-release-x64",
    category = "vm|misc|o64",
)

def dart_vm_sanitizer_builder(name, **kwargs):
    _nightly_builder(
        name,
        channels = ["try"],
        properties = {"bisection_enabled": True},
        **kwargs
    )

dart_vm_sanitizer_builder(
    "vm-asan-linux-release-x64",
    category = "vm|misc|sanitizer|a",
)
dart_vm_sanitizer_builder(
    "vm-msan-linux-release-x64",
    category = "vm|misc|sanitizer|m",
)
dart_vm_sanitizer_builder(
    "vm-tsan-linux-release-x64",
    category = "vm|misc|sanitizer|t",
)
dart_vm_sanitizer_builder(
    "vm-ubsan-linux-release-x64",
    category = "vm|misc|sanitizer|u",
    goma = False,
)  # ubsan is not compatible with our sysroot.
dart_vm_sanitizer_builder(
    "vm-aot-asan-linux-release-x64",
    category = "vm|misc|sanitizer|a",
)
dart_vm_sanitizer_builder(
    "vm-aot-msan-linux-release-x64",
    category = "vm|misc|sanitizer|m",
)
dart_vm_sanitizer_builder(
    "vm-aot-tsan-linux-release-x64",
    category = "vm|misc|sanitizer|t",
)
dart_vm_sanitizer_builder(
    "vm-aot-ubsan-linux-release-x64",
    category = "vm|misc|sanitizer|u",
    goma = False,
)  # ubsan is not compatible with our sysroot.
_nightly_builder(
    "vm-reload-linux-debug-x64",
    category = "vm|misc|reload|d",
    channels = ["try"],
)
_nightly_builder(
    "vm-reload-linux-release-x64",
    category = "vm|misc|reload|r",
    channels = ["try"],
)
_nightly_builder(
    "vm-reload-rollback-linux-debug-x64",
    category = "vm|misc|reload|drb",
    channels = ["try"],
)
_nightly_builder(
    "vm-reload-rollback-linux-release-x64",
    category = "vm|misc|reload|rrb",
    channels = ["try"],
)
_nightly_builder(
    "vm-linux-debug-x64c",
    category = "vm|misc|compressed|jl",
    channels = ["try"],
)
_nightly_builder(
    "vm-aot-linux-debug-x64c",
    category = "vm|misc|compressed|al",
    channels = ["try"],
    properties = slow_shards,
)
_nightly_builder(
    "vm-win-debug-x64c",
    category = "vm|misc|compressed|jw",
    channels = ["try"],
    dimensions = windows,
)
_nightly_builder(
    "vm-aot-win-debug-x64c",
    category = "vm|misc|compressed|aw",
    channels = ["try"],
    dimensions = windows,
    properties = slow_shards,
)
_low_priority_builder(
    "vm-fuchsia-release-arm64",
    category = "vm|misc|f",
    properties = [fuchsia_deps],
)
_low_priority_builder(
    "vm-fuchsia-release-x64",
    category = "vm|misc|f",
    properties = [fuchsia_deps],
)

# Our sysroot does not support gcc, we can't use goma on RBE for this builder
_nightly_builder(
    "vm-gcc-linux",
    category = "vm|misc|g",
    channels = ["try"],
    dimensions = focal,
    execution_timeout = 5 * time.hour,
    goma = False,
    properties = {
        "$dart/build": {
            "timeout": 75 * 60,  # 100 minutes,
        },
    },
)

_nightly_builder(
    "vm-msvc-windows",
    category = "vm|misc|m",
    channels = ["try"],
    dimensions = windows,
    goma = False,
)

# vm|ffi
_extra_builder(
    "vm-ffi-android-debug-arm",
    category = "vm|ffi|d32",
    properties = [android_deps],
)
_extra_builder(
    "vm-ffi-android-release-arm",
    category = "vm|ffi|r32",
    properties = [android_deps],
)
_extra_builder(
    "vm-ffi-android-product-arm",
    category = "vm|ffi|p32",
    properties = [android_deps],
)
_extra_builder(
    "vm-ffi-android-debug-arm64c",
    category = "vm|ffi|d64",
    properties = [android_deps],
)
_extra_builder(
    "vm-ffi-android-release-arm64c",
    category = "vm|ffi|r64",
    properties = [android_deps],
)
_extra_builder(
    "vm-ffi-android-product-arm64c",
    category = "vm|ffi|p64",
    properties = [android_deps],
)
_extra_builder(
    "vm-ffi-qemu-linux-release-arm",
    category = "vm|ffi|qa",
    dimensions = focal,
)
_extra_builder(
    "vm-ffi-qemu-linux-release-riscv64",
    category = "vm|ffi|qr",
    dimensions = focal,
)

# vm|legacy|jit
_nightly_builder(
    "vm-kernel-linux-debug-x64",
    category = "vm|legacy|jit|d",
    channels = ["try"],
)
_nightly_builder(
    "vm-kernel-linux-release-x64",
    category = "vm|legacy|jit|r",
    channels = ["try"],
)

# vm|legacy|aot
_nightly_builder(
    "vm-kernel-precomp-linux-debug-x64",
    category = "vm|legacy|aot|d",
    channels = ["try"],
)
_nightly_builder(
    "vm-kernel-precomp-linux-release-x64",
    category = "vm|legacy|aot|r",
    channels = ["try"],
)

# Isolate stress test builder
_extra_builder(
    "iso-stress-linux",
    channels = [],
    notifies = "dart-vm-team",
    properties = slow_shards,
)
