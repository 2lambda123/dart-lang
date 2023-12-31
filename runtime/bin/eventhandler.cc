// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#include "bin/eventhandler.h"

#include "bin/builtin.h"
#include "bin/dartutils.h"
#include "bin/lockers.h"
#include "bin/socket.h"
#include "bin/thread.h"

#include "include/dart_api.h"

namespace dart {
namespace bin {

static EventHandler* event_handler = nullptr;
static Monitor* shutdown_monitor = nullptr;

void EventHandler::Start() {
  // Initialize global socket registry.
  ListeningSocketRegistry::Initialize();

  ASSERT(event_handler == nullptr);
  shutdown_monitor = new Monitor();
  event_handler = new EventHandler();
  event_handler->delegate_.Start(event_handler);

  if (!SocketBase::Initialize()) {
    FATAL("Failed to initialize sockets");
  }
}

void EventHandler::NotifyShutdownDone() {
  MonitorLocker ml(shutdown_monitor);
  ml.Notify();
}

void EventHandler::Stop() {
  if (event_handler == nullptr) {
    return;
  }

  // Wait until it has stopped.
  {
    MonitorLocker ml(shutdown_monitor);

    // Signal to event handler that we want it to stop.
    event_handler->delegate_.Shutdown();
    ml.Wait(Monitor::kNoTimeout);
  }

  // Cleanup
  delete event_handler;
  event_handler = nullptr;
  delete shutdown_monitor;
  shutdown_monitor = nullptr;

  // Destroy the global socket registry.
  ListeningSocketRegistry::Cleanup();
}

EventHandlerImplementation* EventHandler::delegate() {
  if (event_handler == nullptr) {
    return nullptr;
  }
  return &event_handler->delegate_;
}

void EventHandler::SendFromNative(intptr_t id, Dart_Port port, int64_t data) {
  event_handler->SendData(id, port, data);
}

/*
 * Send data to the EventHandler thread to register for a given instance
 * args[0] a ReceivePort args[1] with a notification event args[2].
 */
void FUNCTION_NAME(EventHandler_SendData)(Dart_NativeArguments args) {
  // Get the id out of the send port. If the handle is not a send port
  // we will get an error and propagate that out.
  Dart_Handle handle = Dart_GetNativeArgument(args, 1);
  Dart_Port dart_port;
  handle = Dart_SendPortGetId(handle, &dart_port);
  if (Dart_IsError(handle)) {
    Dart_PropagateError(handle);
    UNREACHABLE();
  }
  Dart_Handle sender = Dart_GetNativeArgument(args, 0);
  intptr_t id;
  if (Dart_IsNull(sender)) {
    id = kTimerId;
  } else {
    Socket* socket = Socket::GetSocketIdNativeField(sender);
    ASSERT(dart_port != ILLEGAL_PORT);
    socket->set_port(dart_port);
    socket->Retain();  // inc refcount before sending to the eventhandler.
    id = reinterpret_cast<intptr_t>(socket);
  }
  int64_t data = DartUtils::GetIntegerValue(Dart_GetNativeArgument(args, 2));
  event_handler->SendData(id, dart_port, data);
}

void FUNCTION_NAME(EventHandler_TimerMillisecondClock)(
    Dart_NativeArguments args) {
  int64_t now = TimerUtils::GetCurrentMonotonicMillis();
  Dart_SetReturnValue(args, Dart_NewInteger(now));
}

}  // namespace bin
}  // namespace dart
