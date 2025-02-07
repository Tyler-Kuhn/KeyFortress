import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:infrastructure/interfaces/ipage_router_service.dart';
import 'package:shared/locator.dart';

class ActivityObserver with WidgetsBindingObserver {
  static const int _inactivityThresholdSeconds = 30;
  late Timer _inactivityTimer;
  late IPageRouterService _routerService;
  int _passed = 0;

  ActivityObserver() {
    WidgetsBinding.instance?.addObserver(this);
    GestureBinding.instance.pointerRouter
        .addGlobalRoute(_globalUserInteractionHandler);
    Timer.periodic(Duration(seconds: 1), (timer) {
      _passed++;
      print(_passed);
    });
    _routerService = getIt.get<IPageRouterService>();
    _startInactivityTimer();
  }

  void _startInactivityTimer() {
    _inactivityTimer = Timer.periodic(
      Duration(seconds: _inactivityThresholdSeconds),
      (timer) {
        print(
            'No user activity detected for $_inactivityThresholdSeconds seconds.');
        _routerService.router.router.go("/");
      },
    );
  }

  void _resetInactivityTimer() {
    _inactivityTimer.cancel();
    _passed = 0;
    _startInactivityTimer();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        _resetInactivityTimer();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        break;
      case AppLifecycleState.hidden:
    }
  }

  void _globalUserInteractionHandler(PointerEvent event) {
    print(event);
    print("Resetting timer");
    _resetInactivityTimer();
  }

  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    _inactivityTimer.cancel();
  }
}
