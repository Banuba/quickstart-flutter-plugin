import 'dart:async';
import 'dart:io';

import 'package:banuba_sdk/banuba_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

const banubaToken = <#"Place Token here"#>;

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
  final _showCameraMode = true;

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
      home: _showCameraMode ? CameraPage(_banubaSdkManager) : PhotoPage(_banubaSdkManager),
    );
  }
}

/// Sample page for camera screen
/// 1. Open camera
/// 2. Apply Face AR effect
/// 3. Record video(with/out AR effect)
/// 4. Take a picture(with/out AR effect)
class CameraPage extends StatefulWidget {
  final BanubaSdkManager _banubaSdkManager;

  CameraPage(this._banubaSdkManager, {super.key}) {}

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> with WidgetsBindingObserver {
  final _epWidget = EffectPlayerWidget(key: null);

  // The higher resolution the more CPU and GPU resources are used.
  // Please take into account that low level devices might have performance issues with HD resolution.
  final _videoResolutionHD = const Size(720, 1280);

  final _captureAudioInVideoRecording = true;

  bool _applyEffect = false;
  bool _isVideoRecording = false;
  bool _isFacingFront = true;

  @override
  void initState() {
    debugPrint('CameraPageState: init');
    super.initState();

    // It is required to grant all permissions for the plugin: Camera, Micro, Storage
    _requestPermissions().then((granted) {
      if (granted) {
        debugPrint('Thanks! All permissions are granted!');
        openCamera();
      } else {
        debugPrint('WARNING! Not all required permissions are granted!');
        // Plugin cannot be used. Handle this state on your app side
        SystemNavigator.pop();
      }
    }).onError((error, stackTrace) {
      debugPrint('ERROR! Plugin cannot be used : $error');
      // Plugin cannot be used. Handle this state on your app side
      SystemNavigator.pop();
    });
  }

  List<Permission> _getPlatformPermissions() {
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

  // This is a sample implementation of requesting permissions.
  // It is expected that the user grants all permissions. This solution does not handle the case
  // when the user denies access or navigating the user to Settings for granting access.
  // Please implement better permissions handling in your project.
  Future<bool> _requestPermissions() async {
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

  Future<void> openCamera() async {
    debugPrint('CameraPageState: open camera');
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) {
      debugPrint('Warning! widget is not mounted!');
      return;
    }
    await widget._banubaSdkManager.openCamera();
    await widget._banubaSdkManager.attachWidget(_epWidget.banubaId);
    widget._banubaSdkManager.startPlayer();
  }

  Future<void> toggleEffect() async {
    debugPrint('CameraPageState: toggleEffect');
    _applyEffect = !_applyEffect;
    if (_applyEffect) {
      // Applies Face AR effect
      widget._banubaSdkManager.loadEffect('effects/TrollGrandma');
    } else {
      // Discard Face AR effect
      widget._banubaSdkManager.loadEffect('');
    }
  }

  Future<void> handleVideoRecording() async {
    if (_isVideoRecording) {
      debugPrint('CameraPageState: stopVideoRecording');
      _isVideoRecording = false;
      widget._banubaSdkManager.stopVideoRecording();
    } else {
      final filePath = await _generateFilePath('video_', '.mp4');
      debugPrint('CameraPageState: startVideoRecording = $filePath');
      _isVideoRecording = true;
      widget._banubaSdkManager
          .startVideoRecording(filePath, _captureAudioInVideoRecording,
          _videoResolutionHD.width.toInt(), _videoResolutionHD.height.toInt())
          .then((value) => debugPrint('Video recorded successfully'));
    }
  }

  Future<void> takePhoto() async {
    final photoFilePath = await _generateFilePath('image_', '.png');
    debugPrint('Take photo = $photoFilePath');
    widget._banubaSdkManager
        .takePhoto(
        photoFilePath, _videoResolutionHD.width.toInt(), _videoResolutionHD.height.toInt())
        .then((value) => debugPrint('Photo taken successfully'))
        .onError((error, stackTrace) => debugPrint('Error while taking photo'));
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('CameraPageState: build');
    final screenSize = MediaQuery.of(context).size;
    return Stack(
      children: [
        SizedBox(width: screenSize.width, height: screenSize.height, child: _epWidget),
        Positioned(
            top: screenSize.height * 0.7,
            left: screenSize.width * 0.05,
            child: Column(
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: const StadiumBorder(),
                    fixedSize: const Size(120, 40),
                  ),
                  onPressed: () {
                    toggleEffect();
                  },
                  child: Text(
                    'Effect'.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10.0,
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: const StadiumBorder(),
                    fixedSize: const Size(120, 40),
                  ),
                  onPressed: () {
                    _isFacingFront = !_isFacingFront;
                    widget._banubaSdkManager.setCameraFacing(_isFacingFront);
                  },
                  child: Text(
                    'Front/Back'.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10.0,
                    ),
                  ),
                )
              ],
            )),
        Positioned(
            bottom: screenSize.height * 0.03,
            left: screenSize.width * 0.05,
            child: Row(
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: const StadiumBorder(),
                    fixedSize: const Size(120, 40),
                    backgroundColor: _isVideoRecording ? Colors.red : Colors.green,
                  ),
                  onPressed: () {
                    setState(() {
                      handleVideoRecording();
                    });
                  },
                  child: Text(
                    _isVideoRecording ? 'Stop'.toUpperCase() : 'Record Video'.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10.0,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: const StadiumBorder(),
                    fixedSize: const Size(120, 40),
                  ),
                  onPressed: () => takePhoto(),
                  child: Text(
                    'Take Photo'.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10.0,
                    ),
                  ),
                )
              ],
            )),
      ],
    );
  }
}

/// Sample page for applying Face AR effect to an image.
class PhotoPage extends StatefulWidget {
  final BanubaSdkManager _banubaSdkManager;

  PhotoPage(this._banubaSdkManager, {super.key}) {}

  @override
  State<PhotoPage> createState() => _PhotoPageState();
}

class _PhotoPageState extends State<PhotoPage> with WidgetsBindingObserver {
  XFile? _pickedImageFile;
  String? _processedImageFilePath;
  bool _isProcessing = false;

  @override
  void initState() {
    debugPrint('PhotoPageState: init');
    super.initState();
    _pickImage();
  }

  Future<void> _pickImage() async {
    // Use your implementation to provide correct image
    final ImagePicker picker = ImagePicker();
    _pickedImageFile = await picker.pickImage(source: ImageSource.gallery);

    if (_pickedImageFile == null) {
      debugPrint('Warning! Image is not picked');
      SystemNavigator.pop();
    } else {
      debugPrint('Picked image file = ${_pickedImageFile?.path}');
      setState(() {});
    }
  }

  Future<void> processImage() async {
    _isProcessing = true;

    widget._banubaSdkManager.startPlayer();
    widget._banubaSdkManager.loadEffect('effects/TrollGrandma');
    final destFilePath = await _generateFilePath('image_', '.png');

    debugPrint('PhotoPageState: dest = $destFilePath');

    setState(() {});

    widget._banubaSdkManager.processImage(_pickedImageFile!.path, destFilePath).then((value) {
      debugPrint('PhotoPageState: image processed successfully!');
      _processedImageFilePath = destFilePath;
      _isProcessing = false;
      setState(() {});
    }).onError((error, stackTrace) {
      _processedImageFilePath = null;
      _isProcessing = false;
      debugPrint('PhotoPageState: Error while processing image');
    });
  }

  File? findStateFile() {
    final File? imageFile;
    if (_processedImageFilePath == null) {
      if (_pickedImageFile == null) {
        imageFile = null;
      } else {
        imageFile = File(_pickedImageFile!.path);
      }
    } else {
      imageFile = File(_processedImageFilePath!);
    }
    return imageFile;
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final File? imageFile = findStateFile();

    debugPrint('PhotoPageState: build: isProcessing = $_isProcessing, imageFile = $imageFile');

    return Stack(children: [
      imageFile == null
          ? const Text('Pick image from gallery',
          style: TextStyle(
            fontSize: 10.0,
          ))
          : Image.file(
        File(imageFile.path),
        fit: BoxFit.cover,
        height: double.infinity,
        width: double.infinity,
        alignment: Alignment.center,
      ),
      Positioned(
          bottom: screenSize.height * 0.03,
          left: screenSize.width * 0.05,
          child: Visibility(
              visible: _processedImageFilePath == null && !_isProcessing,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: const StadiumBorder(),
                  backgroundColor: Colors.green,
                  fixedSize: const Size(120, 40),
                ),
                onPressed: () => processImage(),
                child: Text(
                  "Effect".toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10.0,
                  ),
                ),
              ))),
      Center(
        child: Visibility(
          visible: _isProcessing,
          child: const CircularProgressIndicator(
            color: Colors.green,
          ),
        ),
      )
    ]);
  }
}

Future<String> _generateFilePath(String prefix, String fileExt) async {
  final directory = await getTemporaryDirectory();
  final filename = '$prefix${DateTime.now().millisecondsSinceEpoch}$fileExt';
  return '${directory.path}${Platform.pathSeparator}$filename';
}
