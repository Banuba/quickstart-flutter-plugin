import 'dart:async';
import 'dart:io';

import 'package:banuba_sdk/banuba_sdk.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:quickstart_flutter_plugin/page_camera.dart';
import 'package:quickstart_flutter_plugin/page_image.dart';
import 'package:quickstart_flutter_plugin/page_touchup.dart';

const banubaToken = <#"Place Token here"#>

enum EntryPage { camera, image, touchUp }

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  // Avoid creating multiple instances
  final _banubaSdkManager = BanubaSdkManager();

  // Use this flag to switch between Camera and Photo modes
  final _entryPage = EntryPage.camera;

  @override
  void initState() {
    super.initState();
    initSDK();
  }

  // Platform messages are asynchronous, so we initialize it in an async method.
  // Avoid calling this method frequently
  Future<void> initSDK() async {
    debugPrint('Init Banuba SDK');

    await _banubaSdkManager.initialize([], banubaToken, SeverityLevel.info);

    debugPrint('Banuba Sdk initialized successfully!');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Face AR Flutter Sample',
        theme: ThemeData(
          primarySwatch: Colors.indigo,
        ),
        home: _createEntryPage());
  }

  StatefulWidget _createEntryPage() {
    switch (_entryPage) {
      case EntryPage.camera:
        return CameraPage(_banubaSdkManager);

      case EntryPage.image:
        return ImagePage(_banubaSdkManager);

      case EntryPage.touchUp:
        return TouchUpPage(_banubaSdkManager);
    }
  }
}

Future<String> generateFilePath(String prefix, String fileExt) async {
  final directory = await getTemporaryDirectory();
  final filename = '$prefix${DateTime.now().millisecondsSinceEpoch}$fileExt';
  return '${directory.path}${Platform.pathSeparator}$filename';
}

// This is a sample implementation of requesting permissions.
// It is expected that the user grants all permissions. This solution does not handle the case
// when the user denies access or navigating the user to Settings for granting access.
// Please implement better permissions handling in your project.
Future<bool> requestPermissions() async {
  final requiredPermissions = getPlatformPermissions();
  for (var permission in requiredPermissions) {
    var ps = await permission.status;
    if (!ps.isGranted) {
      ps = await permission.request();
      if (!ps.isGranted) {
        return false;
      }
    }
  }
  return true;
}

List<Permission> getPlatformPermissions() {
  if (Platform.isAndroid) {
    // Implement check version flow on your side
    final versionHigher11 = true;
    if (versionHigher11) {
      return [Permission.camera, Permission.microphone, Permission.manageExternalStorage];
    } else {
      return [Permission.camera, Permission.microphone, Permission.storage];
    }
  } else if (Platform.isIOS) {
    return [Permission.camera, Permission.microphone];
  } else {
    throw Exception('Platform is not supported!');
  }
}
