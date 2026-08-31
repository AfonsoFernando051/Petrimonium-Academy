import 'dart:async';

import 'package:petrimonium/core/events/app_event.dart';

/// The connective tissue between the Financial Engine, Game Engine and
/// (future) Character Engine: financial/game logic emits an [AppEvent] here
/// instead of reaching into UI/animation code directly, and anything that
/// wants to react — a toast today, a character reaction or the AI Mentor
/// later — subscribes to [stream] instead of being hardwired into the
/// emitter.
class AppEventBus {
  AppEventBus._();

  static final AppEventBus instance = AppEventBus._();

  final _controller = StreamController<AppEvent>.broadcast();

  Stream<AppEvent> get stream => _controller.stream;

  void emit(AppEvent event) => _controller.add(event);
}
