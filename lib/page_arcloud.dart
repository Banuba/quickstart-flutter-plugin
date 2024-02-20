import 'dart:async';

import 'package:banuba_arcloud/banuba_arcloud.dart';
import 'package:banuba_sdk/banuba_sdk.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'main.dart';

class ARCloudPage extends StatefulWidget {
  const ARCloudPage({super.key});

  @override
  State<ARCloudPage> createState() => _ARCloudPageState();
}

class _ARCloudPageState extends State<ARCloudPage> with WidgetsBindingObserver {
  static const _tag = 'ARCloud';

  static const _arCloudUrl = '';

  bool _isProcessing = false;

  final BanubaSdkManager _banubaSdkManager = BanubaSdkManager();
  final _epWidget = EffectPlayerWidget(key: null);

  final _arCloudPlugin = BanubaARCloudPlugin();
  late StreamSubscription<void> _effectsStreamSubscription;
  Effect? _effectToDownload;
  bool requestToDownload = false;

  @override
  void initState() {
    debugPrint('$_tag: init');
    super.initState();
    initSDK();
  }

  @override
  void dispose() {
    super.dispose();
    debugPrint('$_tag: release SDK and AR Cloud');
    // Dispose AR Cloud
    _effectsStreamSubscription.cancel();
    _arCloudPlugin.dispose();

    // Dispose Banuba SDK
    _banubaSdkManager.stopPlayer();
    _banubaSdkManager.closeCamera();
    _banubaSdkManager.deinitialize();
  }

  Future<void> initSDK() async {
    debugPrint('$_tag: init SDK');

    await _banubaSdkManager.initialize([], banubaToken, SeverityLevel.info);

    // It is required to grant all permissions for the plugin: Camera
    requestPermissions().then((granted) {
      if (granted) {
        debugPrint('$_tag: Thanks! Camera permission is granted!');
        openCamera();
      } else {
        debugPrint('$_tag: WARNING! Camera permission is not granted!');
        // Plugin cannot be used. Handle this state on your app side
        SystemNavigator.pop();
      }
    }).onError((error, stackTrace) {
      debugPrint('$_tag: ERROR! Plugin cannot be used : $error');
      // Plugin cannot be used. Handle this state on your app side
      SystemNavigator.pop();
    });

    // Subscribe to getting effect changes.
    // List of effects contain local and remote effects.
    // The list gets changes when effect is downloaded.
    _effectsStreamSubscription = _arCloudPlugin.getEffectsStream().listen(
          _handleLoadedEffects,
          onError: (e) => _showMessage(e.toString()),
        );
    _arCloudPlugin.init(arCloudUrl: _arCloudUrl);

    debugPrint('$_tag: SDK and ARCloud initialized successfully');
  }

  Future<void> openCamera() async {
    debugPrint('$_tag: open camera');
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) {
      debugPrint('$_tag: Warning! widget is not mounted!');
      return;
    }
    await _banubaSdkManager.openCamera();
    await _banubaSdkManager.attachWidget(_epWidget.banubaId);
    await _banubaSdkManager.unloadEffect();

    _banubaSdkManager.startPlayer();
  }

  Future<void> loadEffects() async {
    debugPrint('$_tag: loadEffects');
    _isProcessing = true;

    // Reset load effect state
    _effectToDownload = null;
    requestToDownload = true;

    setState(() {});

    _arCloudPlugin.loadEffects();
  }

  Future<void> _handleLoadedEffects(List<Effect> allEffects) async {
    debugPrint('$_tag: _handleLoadedEffects, effectToDownload = $_effectToDownload');

    // The sample demonstrates how to download new effect from AR Cloud, how to apply once this
    // effect is downloaded.
    // Your implementation might be very different.
    // Anyway you will need to operate with list of all effects - local, remote.
    // The effect is considered as local once it is downloaded.
    // You can apply or play only local effects.

    if (allEffects.isEmpty) {
      _isProcessing = false;
      _showMessage("No available effects!");
      setState(() {});

      return;
    }

    // Check if there pending effect to download
    if (_effectToDownload != null) {
      final downloadedEffect =
          allEffects.firstWhereOrNull((element) => element.eTag == _effectToDownload!.eTag);
      debugPrint('$_tag: _handleLoadedEffects, downloadedEffect = $downloadedEffect');
      if (downloadedEffect != null && downloadedEffect.isDownloaded) {
        // Great! Effect is downloaded and prepared to be applied
        _isProcessing = false;
        _banubaSdkManager.loadEffect(downloadedEffect.uri, false);

        setState(() {});
      }
      return;
    }

    if (requestToDownload) {
      // Find the first not downloaded effect
      _effectToDownload = allEffects.firstWhereOrNull((element) => !element.isDownloaded);

      debugPrint('$_tag: Found effect to download = $_effectToDownload');

      if (_effectToDownload == null) {
        debugPrint('$_tag: No available effects to download');
        return;
      } else {
        try {
          // Download effect. The stream will be updated once the effect is downloaded
          await _arCloudPlugin.downloadEffect(_effectToDownload!.name);
        } on Exception catch (e) {
          _showMessage(e.toString());
          return;
        } finally {
          requestToDownload = false;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    debugPrint('$_tag: build: isProcessing = $_isProcessing');

    return Stack(children: [
      SizedBox(width: screenSize.width, height: screenSize.height, child: _epWidget),
      Positioned(
          bottom: screenSize.height * 0.03,
          left: screenSize.width * 0.35,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: const StadiumBorder(),
              backgroundColor: Colors.green,
              fixedSize: const Size(120, 40),
            ),
            onPressed: () => loadEffects(),
            child: Text(
              "Load Effect".toUpperCase(),
              style: const TextStyle(
                fontSize: 10.0,
              ),
            ),
          )),
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

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }
}
