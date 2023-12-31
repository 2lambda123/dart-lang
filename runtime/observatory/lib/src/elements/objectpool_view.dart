// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library objectpool_view;

import 'dart:async';
import 'dart:html';
import 'package:observatory/models.dart' as M;
import 'package:observatory/src/elements/helpers/any_ref.dart';
import 'package:observatory/src/elements/helpers/nav_bar.dart';
import 'package:observatory/src/elements/helpers/nav_menu.dart';
import 'package:observatory/src/elements/helpers/rendering_scheduler.dart';
import 'package:observatory/src/elements/helpers/custom_element.dart';
import 'package:observatory/src/elements/nav/isolate_menu.dart';
import 'package:observatory/src/elements/nav/notify.dart';
import 'package:observatory/src/elements/nav/refresh.dart';
import 'package:observatory/src/elements/nav/top_menu.dart';
import 'package:observatory/src/elements/nav/vm_menu.dart';
import 'package:observatory/src/elements/object_common.dart';

class ObjectPoolViewElement extends CustomElement implements Renderable {
  late RenderingScheduler<ObjectPoolViewElement> _r;

  Stream<RenderedEvent<ObjectPoolViewElement>> get onRendered => _r.onRendered;

  late M.VM _vm;
  late M.IsolateRef _isolate;
  late M.EventRepository _events;
  late M.NotificationRepository _notifications;
  late M.ObjectPool _pool;
  late M.ObjectPoolRepository _pools;
  late M.RetainedSizeRepository _retainedSizes;
  late M.ReachableSizeRepository _reachableSizes;
  late M.InboundReferencesRepository _references;
  late M.RetainingPathRepository _retainingPaths;
  late M.ObjectRepository _objects;

  M.VMRef get vm => _vm;
  M.IsolateRef get isolate => _isolate;
  M.NotificationRepository get notifications => _notifications;
  M.ObjectPoolRef get pool => _pool;

  factory ObjectPoolViewElement(
      M.VM vm,
      M.IsolateRef isolate,
      M.ObjectPool pool,
      M.EventRepository events,
      M.NotificationRepository notifications,
      M.ObjectPoolRepository pools,
      M.RetainedSizeRepository retainedSizes,
      M.ReachableSizeRepository reachableSizes,
      M.InboundReferencesRepository references,
      M.RetainingPathRepository retainingPaths,
      M.ObjectRepository objects,
      {RenderingQueue? queue}) {
    ObjectPoolViewElement e = new ObjectPoolViewElement.created();
    e._r = new RenderingScheduler<ObjectPoolViewElement>(e, queue: queue);
    e._vm = vm;
    e._isolate = isolate;
    e._events = events;
    e._notifications = notifications;
    e._pool = pool;
    e._pools = pools;
    e._retainedSizes = retainedSizes;
    e._reachableSizes = reachableSizes;
    e._references = references;
    e._retainingPaths = retainingPaths;
    e._objects = objects;
    return e;
  }

  ObjectPoolViewElement.created() : super.created('object-pool-view');

  @override
  attached() {
    super.attached();
    _r.enable();
  }

  @override
  detached() {
    super.detached();
    _r.disable(notify: true);
    children = <Element>[];
  }

  void render() {
    children = <Element>[
      navBar(<Element>[
        new NavTopMenuElement(queue: _r.queue).element,
        new NavVMMenuElement(_vm, _events, queue: _r.queue).element,
        new NavIsolateMenuElement(_isolate, _events, queue: _r.queue).element,
        navMenu('instance'),
        (new NavRefreshElement(queue: _r.queue)
              ..onRefresh.listen((e) async {
                e.element.disabled = true;
                _pool = await _pools.get(_isolate, _pool.id!);
                _r.dirty();
              }))
            .element,
        new NavNotifyElement(_notifications, queue: _r.queue).element
      ]),
      new DivElement()
        ..classes = ['content-centered-big']
        ..children = <Element>[
          new HeadingElement.h2()..text = 'ObjectPool',
          new HRElement(),
          new ObjectCommonElement(_isolate, _pool, _retainedSizes,
                  _reachableSizes, _references, _retainingPaths, _objects,
                  queue: _r.queue)
              .element,
          new HRElement(),
          new HeadingElement.h3()..text = 'entries (${_pool.entries!.length})',
          new DivElement()
            ..classes = ['memberList']
            ..children = _pool.entries!
                .map<Element>((entry) => new DivElement()
                  ..classes = ['memberItem']
                  ..children = <Element>[
                    new DivElement()
                      ..classes = ['memberName', 'hexadecimal']
                      ..text = '[PP+0x${entry.offset.toRadixString(16)}]',
                    new DivElement()
                      ..classes = ['memberName']
                      ..children = _createEntry(entry)
                  ])
                .toList(),
        ]
    ];
  }

  List<Element> _createEntry(M.ObjectPoolEntry entry) {
    switch (entry.kind) {
      case M.ObjectPoolEntryKind.nativeEntryData:
      case M.ObjectPoolEntryKind.object:
        return [anyRef(_isolate, entry.asObject, _objects, queue: _r.queue)];
      case M.ObjectPoolEntryKind.immediate:
        return [new SpanElement()..text = 'Immediate ${entry.asImmediate!}'];
      case M.ObjectPoolEntryKind.nativeEntry:
        return [new SpanElement()..text = 'NativeEntry ${entry.asImmediate!}'];
    }
  }
}
