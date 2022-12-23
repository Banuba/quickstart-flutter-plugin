import 'package:flutter/material.dart';
import 'dart:async';

import 'package:banuba_sdk/banuba_sdk.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final _banubaSdkManager = BanubaSdkManager();
  final _epWidget = EffectPlayerWidget(key: null);

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    await _banubaSdkManager.initialize([],
        <#"Place Token here"#>,
        SeverityLevel.info);

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {});
    await _banubaSdkManager.openCamera();
    await _banubaSdkManager.attachWidget(_epWidget.banubaId);

    await _banubaSdkManager.startPlayer();
    await _banubaSdkManager.loadEffect("effects/TrollGrandma");
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: _epWidget);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _banubaSdkManager.startPlayer();
    } else {
      _banubaSdkManager.stopPlayer();
    }
  }
}