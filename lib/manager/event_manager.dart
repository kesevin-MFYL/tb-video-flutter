import 'dart:async';

import 'package:event_bus/event_bus.dart';

enum EventBusName {
  playVideo,
}

class EventBusModel {
  EventBusModel({required this.name, this.value});

  EventBusName name;
  dynamic value;
}

class EventBusManager {
  static final instance = EventBusManager._();

  EventBusManager._();

  EventBus eventBus = EventBus();

  void post(EventBusName eventBusName, {dynamic value}) {
    eventBus.fire(EventBusModel(name: eventBusName, value: value));
  }

  StreamSubscription<EventBusModel> addObserver(EventBusName eventBusName, void Function(dynamic value) block) {
    return eventBus.on<EventBusModel>().listen((event) {
      if (event.name == eventBusName) {
        block(event.value);
      }
    });
  }
}