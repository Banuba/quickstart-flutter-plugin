import 'dart:async';
import 'dart:io';

import 'package:banuba_sdk/banuba_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import 'main.dart';

class ImagePage extends StatefulWidget {
  final BanubaSdkManager _banubaSdkManager;

  ImagePage(this._banubaSdkManager, {super.key}) {}

  @override
  State<ImagePage> createState() => _ImagePageState();
}

class _ImagePageState extends State<ImagePage> with WidgetsBindingObserver {
  XFile? _pickedImageFile;
  String? _processedImageFilePath;
  bool _isProcessing = false;

  @override
  void initState() {
    debugPrint('ImagePage: init');
    super.initState();
    _pickImage();
  }

  Future<void> _pickImage() async {
    // Use your implementation to provide correct image
    final ImagePicker picker = ImagePicker();
    _pickedImageFile = await picker.pickImage(source: ImageSource.gallery);

    if (_pickedImageFile == null) {
      debugPrint('ImagePage: Warning! Image is not picked');
      SystemNavigator.pop();
    } else {
      debugPrint('ImagePage: Picked image file = ${_pickedImageFile?.path}');
      setState(() {});
    }
  }

  Future<void> processImage() async {
    _isProcessing = true;

    widget._banubaSdkManager.startPlayer();
    widget._banubaSdkManager.loadEffect('effects/TrollGrandma');
    final destFilePath = await generateFilePath('image_', '.png');

    debugPrint('ImagePage: process image dest = $destFilePath');

    setState(() {});

    widget._banubaSdkManager.processImage(_pickedImageFile!.path, destFilePath).then((value) {
      debugPrint('ImagePage: image processed successfully!');
      _processedImageFilePath = destFilePath;
      _isProcessing = false;
      setState(() {});
    }).onError((error, stackTrace) {
      _processedImageFilePath = null;
      _isProcessing = false;
      debugPrint('ImagePage: Error while processing image');
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

    debugPrint('ImagePage: build: isProcessing = $_isProcessing, imageFile = $imageFile');

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