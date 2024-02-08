import 'dart:async';
import 'dart:io';

import 'package:banuba_sdk_example/page_camera.dart';
import 'package:banuba_sdk_example/page_image.dart';
import 'package:banuba_sdk_example/page_touchup.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:fluttertoast/fluttertoast.dart';

const banubaToken = <#"Place Token here"#>

enum EntryPage { camera, image, touchUp }

void main() {
  runApp(const MaterialApp(home: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  Widget build(BuildContext context) {
    final buttonStyle = ElevatedButton.styleFrom(
      shape: const StadiumBorder(),
      fixedSize: Size(MediaQuery.of(context).size.width / 2.0, 50),
    );
    Text textWidget(String text) {
      return Text(
        text.toUpperCase(),
        style: const TextStyle(fontSize: 13.0),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Face AR Flutter Sample'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ElevatedButton(
            style: buttonStyle,
            onPressed: () => _navigateToPage(EntryPage.camera),
            child: textWidget('Open Camera'),
          ),
          SizedBox.fromSize(size: const Size.fromHeight(20.0)),
          ElevatedButton(
            style: buttonStyle,
            onPressed: () => _navigateToPage(EntryPage.image),
            child: textWidget('Image processing'),
          ),
          SizedBox.fromSize(size: const Size.fromHeight(20.0)),
          ElevatedButton(
            style: buttonStyle,
            onPressed: () => _navigateToPage(EntryPage.touchUp),
            child: textWidget('Touch Up features'),
          ),
        ],
      ),
    );
  }

  void _navigateToPage(EntryPage entryPage) {
    switch (entryPage) {
      case EntryPage.camera:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CameraPage()),
        );
        return;

      case EntryPage.image:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ImagePage()),
        );
        return;

      case EntryPage.touchUp:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const TouchUpPage()),
        );
        return;
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
  final requiredPermissions = _getPlatformPermissions();
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

List<Permission> _getPlatformPermissions() {
  if (Platform.isAndroid) {
    return [Permission.camera, Permission.microphone, Permission.storage];
  } else if (Platform.isIOS) {
    return [Permission.camera, Permission.microphone];
  } else {
    throw Exception('Platform is not supported!');
  }
}

void showToastMessage(String message) {
  Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      textColor: Colors.white,
      fontSize: 14.0
  );
}
