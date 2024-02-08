import 'dart:async';

import 'package:banuba_sdk/banuba_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'main.dart';

typedef List<String> Processor(double progress);

class TouchUpPage extends StatefulWidget {
  const TouchUpPage({super.key});

  @override
  State<TouchUpPage> createState() => _TouchUpPageState();
}

class _TouchUpPageState extends State<TouchUpPage> with WidgetsBindingObserver {
  final BanubaSdkManager _banubaSdkManager = BanubaSdkManager();
  final _epWidget = EffectPlayerWidget(key: null);

  final List<Feature> _features = <Feature>[
    /// Main
    Feature(
      name: 'Smooth',
      progressValue: 0.0,
      min: 0,
      max: 100.0,
      processor: (double progress) => ['Skin.softening($progress)']
    ),
    Feature(
        name: 'Eyes',
        progressValue: 0.0,
        min: -100.0,
        max: 100.0,
        processor: (double progress) => ['FaceMorph.eyes({enlargement: $progress})']
    ),
    Feature(
        name: 'Nose',
        progressValue: 0.0,
        min: -100.0,
        max: 100.0,
        processor: (double progress) {
          final w = 1.0 * progress;
          final l = 1.0 * progress;
          final tw = -1.0 * progress;
          return ['FaceMorph.nose({width: $w, length: $l, tip_width: $tw})'];
        }
    ),
    Feature(
        name: 'Lip Size',
        progressValue: 0.0,
        min: -100.0,
        max: 100.0,
        processor: (double progress) => ['FaceMorph.lips({size: $progress})']
    ),
    Feature(
        name: 'Lip Shape',
        progressValue: 0.0,
        min: -100.0,
        max: 100.0,
        processor: (double progress) => ['aceMorph.lips({shape: 1.0, thickness: $progress})']
    ),
    Feature(
        name: 'Face Width',
        progressValue: 0.0,
        min: -100.0,
        max: 100.0,
        processor: (double progress) => ['FaceMorph.face({narrowing: $progress})']
    ),
    Feature(
        name: 'Cheeckbones',
        progressValue: 0.0,
        min: -100.0,
        max: 100.0,
        processor: (double progress) => ['FaceMorph.face({cheekbones_narrowing: $progress})']
    ),
    Feature(
        name: 'Chin',
        progressValue: 0.0,
        min: 0,
        max: 100.0,
        processor: (double progress) => [
              'FaceMesh.chin_jaw_shortening($progress)',
              'FaceMorph.face({jaw_narrowing: 1.0, chin_narrowing: 1.0})'
            ]),
    Feature(
        name: 'Brightening',
        progressValue: 0.0,
        min: 0,
        max: 100.0,
        processor: (double progress) => ['Eyes.whitening($progress)']
    ),
    Feature(
        name: 'Whitening',
        progressValue: 0.0,
        min: 0,
        max: 100.0,
        processor: (double progress) => ['Teeth.whitening($progress)']
    ),

    /// Additional
    Feature(
      name: 'Brow Spacing',
      progressValue: 0.0,
      min: -100.0,
      max: 100.0,
      processor: (double progress) => ['FaceMorph.eyebrows({spacing: $progress})'],
    ),
    Feature(
      name: 'Brow Height',
      progressValue: 0.0,
      min: -100.0,
      max: 100.0,
      processor: (double progress) => ['FaceMorph.eyebrows({height: $progress})'],
    ),
    Feature(
      name: 'Brow Bend',
      progressValue: 0.0,
      min: -100.0,
      max: 100.0,
      processor: (double progress) => ['FaceMorph.eyebrows({bend: $progress})'],
    ),
    Feature(
      name: 'Eyes Rounding',
      progressValue: 0.0,
      min: 0.0,
      max: 100.0,
      processor: (double progress) => ['FaceMorph.eyes({rounding: $progress})'],
    ),
    Feature(
      name: 'Eyes Height',
      progressValue: 0.0,
      min: -100.0,
      max: 100.0,
      processor: (double progress) => ['FaceMorph.eyes({height: $progress})'],
    ),
    Feature(
      name: 'Eyes Spacing',
      progressValue: 0.0,
      min: -100.0,
      max: 100.0,
      processor: (double progress) => ['FaceMorph.eyes({spacing: $progress})'],
    ),
    Feature(
      name: 'Eyes Squint',
      progressValue: 0.0,
      min: -100.0,
      max: 100.0,
      processor: (double progress) => ['FaceMorph.eyes({squint: $progress})'],
    ),
    Feature(
      name: 'Upper eyelid',
      progressValue: 0.0,
      min: -100.0,
      max: 100.0,
      processor: (double progress) => ['FaceMorph.eyes({upper_eyelid_pos: $progress})'],
    ),
    Feature(
      name: 'Lower eyelid',
      progressValue: 0.0,
      min: -100.0,
      max: 100.0,
      processor: (double progress) => ['FaceMorph.eyes({lower_eyelid_pos: $progress})'],
    ),
    Feature(
      name: 'Nose Upper Size',
      progressValue: 0.0,
      min: -100.0,
      max: 100.0,
      processor: (double progress) => ['FaceMorph.nose({width: $progress})'],
    ),
    Feature(
      name: 'Nose Length',
      progressValue: 0.0,
      min: -100.0,
      max: 100.0,
      processor: (double progress) => ['FaceMorph.nose({width: $progress})'],
    ),
    Feature(
      name: 'Nostrials',
      progressValue: 0.0,
      min: -100.0,
      max: 100.0,
      processor: (double progress) => ['FaceMorph.nose({tip_width: $progress})'],
    ),
    Feature(
      name: 'Mouth position',
      progressValue: 0.0,
      min: -100.0,
      max: 100.0,
      processor: (double progress) => ['FaceMorph.lips({height: $progress})'],
    ),
    Feature(
      name: 'Lip Thickness',
      progressValue: 0.0,
      min: -100.0,
      max: 100.0,
      processor: (double progress) => ['FaceMorph.lips({thickness: $progress})'],
    ),
    Feature(
      name: 'Mouth Width',
      progressValue: 0.0,
      min: -100.0,
      max: 100.0,
      processor: (double progress) => ['FaceMorph.lips({mouth_size: $progress})'],
    ),
    Feature(
      name: 'Smile',
      progressValue: 0.0,
      min: 0.0,
      max: 100.0,
      processor: (double progress) => ['FaceMorph.lips({smile: $progress})'],
    ),
    Feature(
      name: 'Mouth Shape',
      progressValue: 0.0,
      min: -100.0,
      max: 100.0,
      processor: (double progress) => ['FaceMorph.lips({shape: $progress, thickness: 1.0})'],
    ),
    Feature(
      name: 'Face V-Shape',
      progressValue: 0.0,
      min: -100.0,
      max: 100.0,
      processor: (double progress) => ['FaceMorph.face({v_shape: $progress})'],
    ),
    Feature(
      name: 'Cheeks size',
      progressValue: 0.0,
      min: -100.0,
      max: 100.0,
      processor: (double progress) => ['FaceMorph.face({cheeks_narrowing: $progress})'],
    ),
    Feature(
      name: 'Jaw Width',
      progressValue: 0.0,
      min: -100.0,
      max: 100.0,
      processor: (double progress) => ['FaceMorph.face({jaw_narrowing: $progress})'],
    ),
    Feature(
      name: 'Chin Length',
      progressValue: 0.0,
      min: -100.0,
      max: 100.0,
      processor: (double progress) => ['FaceMorph.face({chin_shortening: $progress})'],
    ),
    Feature(
      name: 'Chin Width',
      progressValue: 0.0,
      min: -100.0,
      max: 100.0,
      processor: (double progress) => ['FaceMorph.face({chin_narrowing: $progress})'],
    ),
    Feature(
      name: 'Cheek Sunken',
      progressValue: 0.0,
      min: 0.0,
      max: 100.0,
      processor: (double progress) => ['FaceMorph.face({sunken_cheeks: $progress})'],
    ),
    Feature(
      name: 'Сheeks & Jaw width',
      progressValue: 0.0,
      min: -100.0,
      max: 100.0,
      processor: (double progress) => ['FaceMorph.face({cheeks_jaw_narrowing: $progress})'],
    ),
  ];

  @override
  void initState() {
    debugPrint('TouchUpPage: init');
    super.initState();

    initSDK();

    // It is required to grant all permissions for the plugin: Camera, Micro, Storage
    requestPermissions().then((granted) {
      if (granted) {
        debugPrint('TouchUpPage: Thanks! All permissions are granted!');
        openCamera();
      } else {
        debugPrint('TouchUpPage: WARNING! Not all required permissions are granted!');
        // Plugin cannot be used. Handle this state on your app side
        SystemNavigator.pop();
      }
    }).onError((error, stackTrace) {
      debugPrint('TouchUpPage: ERROR! Plugin cannot be used : $error');
      // Plugin cannot be used. Handle this state on your app side
      SystemNavigator.pop();
    });
  }

  @override
  void dispose() {
    super.dispose();
    debugPrint('TouchUpPage: release SDK');
    _banubaSdkManager.deinitialize();
  }

  // Platform messages are asynchronous, so we initialize it in an async method.
  // Avoid calling this method frequently
  Future<void> initSDK() async {
    debugPrint('TouchUpPage: start init SDK');

    await _banubaSdkManager.initialize([], banubaToken, SeverityLevel.info);

    debugPrint('TouchUpPage: SDK initialized successfully');
  }

  Future<void> openCamera() async {
    debugPrint('TouchUpPage: open camera');
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) {
      debugPrint('TouchUpPage: Warning! widget is not mounted!');
      return;
    }
    await _banubaSdkManager.openCamera();
    await _banubaSdkManager.attachWidget(_epWidget.banubaId);
    _banubaSdkManager.startPlayer();
    _banubaSdkManager.loadEffect('effects/TouchUp', false);
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('TouchUpPage: build');
    final screenSize = MediaQuery.of(context).size;
    return Material(
        child: Stack(
      children: [
        SizedBox(width: screenSize.width, height: screenSize.height, child: _epWidget),
        Container(
            alignment: Alignment.bottomLeft,
            child: Container(
              height: screenSize.height * 0.33,
              child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                  itemCount: _features.length,
                  itemBuilder: (BuildContext context, int index) =>
                      _buildFeatureItem(_features[index], (index + 1))),
            ))
      ],
    ));
  }

  Widget _buildFeatureItem(Feature feature, int index) => Row(
        children: [
          Text(
            '$index. ${feature.name.toUpperCase()}',
            style: const TextStyle(
                fontSize: 10.0, color: Colors.greenAccent, fontWeight: FontWeight.bold),
          ),
          Slider(
            min: feature.min,
            value: feature.progressValue,
            max: feature.max,
            label: "",
            onChanged: (double value) {
              setState(() {
                feature.progressValue = value;
                _applyBeautyChanges(feature.processor(value / 100));
              });
            },
          )
        ],
      );

  void _applyBeautyChanges(List<String> changes) async {
    for (var element in changes) {
      debugPrint('TouchUpPage: apply effect changes = $element');
      _banubaSdkManager.evalJs(element);
    }
  }
}

class Feature {
  String name;
  double progressValue;
  Processor processor;
  double min;
  double max;

  Feature(
      {required this.name,
      required this.progressValue,
      required this.processor,
      required this.min,
      required this.max});
}
