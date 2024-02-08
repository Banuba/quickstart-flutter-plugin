import 'dart:async';

import 'package:banuba_sdk/banuba_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import 'main.dart';

class ImagePage extends StatefulWidget {
  const ImagePage({super.key});

  @override
  State<ImagePage> createState() => _ImagePageState();
}

class _ImagePageState extends State<ImagePage> with WidgetsBindingObserver {
  final _epWidget = EffectPlayerWidget(key: null);

  XFile? _pickedImageFile;
  bool _isProcessing = false;
  bool _isTouchUpEffect = false;
  double _touchUpProgressValue = 0.0;

  final BanubaSdkManager _banubaSdkManager = BanubaSdkManager();

  @override
  void initState() {
    super.initState();
    initSDK();
  }

  @override
  void dispose() {
    super.dispose();
    debugPrint('ImagePage: release SDK');
    _banubaSdkManager.discardEditingImage();
    _banubaSdkManager.deinitialize();
  }

  Future<void> initSDK() async {
    debugPrint('ImagePage: init SDK');

    await _banubaSdkManager.initialize([], banubaToken, SeverityLevel.info);

    debugPrint('ImagePage: SDK initialized successfully');
  }

  Future<void> _pickImage() async {
    // Use your implementation to provide correct image
    final ImagePicker picker = ImagePicker();
    _pickedImageFile = await picker.pickImage(source: ImageSource.gallery);

    if (_pickedImageFile == null) {
      debugPrint('ImagePage: Warning! Image is not picked');
      SystemNavigator.pop();
      return;
    }
    debugPrint('ImagePage: Picked image file = ${_pickedImageFile!.path}');

    setState(() {});

    await _banubaSdkManager.attachWidget(_epWidget.banubaId);
    await _banubaSdkManager.startPlayer();
    await _banubaSdkManager.startEditingImage(_pickedImageFile!.path);
  }

  Future<void> _applyNormaEffect() async {
    _banubaSdkManager.discardEditingImage();
    await _banubaSdkManager.loadEffect('effects/80s', false);

    // Image should exists
    await _banubaSdkManager.startEditingImage(_pickedImageFile!.path);

    setState(() {
      _isTouchUpEffect = false;
    });
  }

  Future<void> _applyTouchUpEffect() async {
    _banubaSdkManager.discardEditingImage();
    await _banubaSdkManager.loadEffect('effects/TouchUp', true);

    // Image should exists
    await _banubaSdkManager.startEditingImage(_pickedImageFile!.path);

    setState(() {
      _isProcessing = false;
      _isTouchUpEffect = true;
    });
  }

  Future<void> _saveImage() async {
    setState(() {
      _isProcessing = true;
    });

    final imageFilePath = await generateFilePath('image_', '.png');

    _banubaSdkManager.endEditingImage(imageFilePath).then((value) {
      debugPrint('ImagePage: Image saved at path $imageFilePath');
      showToastMessage("Edited image saved successfully");
      setState(() {
        _isProcessing = false;
      });
    }).onError((error, stackTrace) {
      debugPrint('ImagePage: Error while saving image $error');
      showToastMessage("Error while saving edited image");
      setState(() {
        _isProcessing = false;
      });
    });
  }

  void _applyBeautyChanges(String change) async {
    debugPrint('ImagePage: apply effect changes = $change');
    await _banubaSdkManager.evalJs(change);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    Widget actionButton(String title, bool visible, void Function() action) {
      return Visibility(
          visible: visible,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: const StadiumBorder(),
              backgroundColor: Colors.green,
              fixedSize: const Size(120, 40),
            ),
            onPressed: action,
            child: Text(
              title.toUpperCase(),
              style: const TextStyle(
                fontSize: 10.0,
              ),
            ),
          ));
    }

    final imageEmpty = _pickedImageFile == null;

    return Stack(children: [
      SizedBox(width: screenSize.width, height: screenSize.height, child: _epWidget),
      Positioned(
        bottom: screenSize.height * 0.15,
        left: screenSize.width * 0.05,
        child: Visibility(
          visible: !_isProcessing,
          child: Column(
            children: [
              actionButton("Pick Image", imageEmpty, () => _pickImage()),
              actionButton("Apply Effect", !imageEmpty, () => _applyNormaEffect()),
              actionButton("Apply Beauty", !imageEmpty, () => _applyTouchUpEffect()),
              actionButton("Save Image", !imageEmpty, () => _saveImage()),
            ],
          ),
        ),
      ),
      Positioned(
          bottom: screenSize.height * 0.05,
          left: screenSize.width * 0.10,
          child: Visibility(
              visible: _isTouchUpEffect && !_isProcessing,
              child: Row(
                children: [
                  const Text(
                    'Smooth',
                    style: TextStyle(
                        fontSize: 16.0, color: Colors.greenAccent, fontWeight: FontWeight.bold),
                  ),
                  Card(
                      child: Slider(
                    min: 0.0,
                    value: _touchUpProgressValue,
                    max: 100.0,
                    label: "",
                    onChanged: (double value) {
                      setState(() {
                        _touchUpProgressValue = value;
                        _applyBeautyChanges('Skin.softening(${value / 100})');
                      });
                    },
                  ))
                ],
              ))),
      Center(
        child: Visibility(
          visible: _isProcessing,
          child: const CircularProgressIndicator(
            color: Colors.green,
          ),
        ),
      ),
      Center(
        child: Visibility(
          visible: _pickedImageFile == null,
          child: const Text(
            'No image selected.\nPlease pick image',
            style: TextStyle(
              fontSize: 20.0,
              color: Colors.red,
            ),
          ),
        ),
      )
    ]);
  }
}
