[![](https://www.banuba.com/hubfs/Banuba_November2018/Images/Banuba%20SDK.png)](https://docs.banuba.com/)

## Quick start example for integrating [Banuba SDK](https://banuba.com/) into Flutter apps.  

## [Requirements](https://docs.banuba.com/face-ar-sdk-v1/overview/system_requirements)

## Usage

### Token
Before you commit to a license, you are free to test all the features of the SDK for free. To start it, [send us a message](https://www.banuba.com/facear-sdk/face-filters#form).  


Feel free to [contact us](https://docs.banuba.com/face-ar-sdk-v1/support) if you have any questions.

### Getting Started

0. Clone the repository, ensure that you have installed [Flutter](https://docs.flutter.dev/get-started/install).
1. Copy and Paste your client token into appropriate section of [`lib/main.dart`](lib/main.dart#L30).
2. Run `flutter pub get`. This command will install all required dependences.
3. Connect a device and run `flutter run`.

### Integration steps

This is how to integrate Banuba SDK Flutter plugin into your existing app. You still need a Client Token for this.

1. Add `banuba_sdk` plugin: `flutter pub add banuba_sdk`.
2. For iOS: add link to native Banuba SDK into `ios/Podfile`: `source 'https://github.com/sdk-banuba/banuba-sdk-podspecs.git'`
3. Add code from [`lib/main.dart`](lib/main.dart) into your app.
4. Add `effects` folder into your project. Link it with your app
    1. iOS: just link effects folder into `Runner` Xcode project (`File` -> `Add Files to 'Runner'...`).
    2. Android: Add [the following](android/app/build.gradle#L61) code into app `build.gradle`.

### Docs
You can find more info [here](https://docs.banuba.com/).
