import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zikirmatik/app/orientation.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Spec 0012, CB-1: the app asks the platform for upright only.
  test('the app locks to portrait', () async {
    final calls = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          calls.add(call);
          return null;
        });
    addTearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null),
    );

    await lockPortrait();

    final orientationCalls = calls.where(
      (c) => c.method == 'SystemChrome.setPreferredOrientations',
    );
    expect(orientationCalls, hasLength(1));
    expect(orientationCalls.single.arguments, ['DeviceOrientation.portraitUp']);
  });

  // Spec 0012, CB-2: the launcher activity is upright from its first frame.
  test('the manifest locks the activity to portrait', () {
    final manifest = File(
      'android/app/src/main/AndroidManifest.xml',
    ).readAsStringSync();
    final activities = RegExp(
      r'<activity\b([^>]*)>(.*?)</activity>',
      dotAll: true,
    ).allMatches(manifest);
    final launcher = activities.where(
      (a) => a.group(2)!.contains('android.intent.action.MAIN'),
    );

    expect(launcher, hasLength(1));
    expect(
      launcher.single.group(1),
      contains('android:screenOrientation="portrait"'),
    );
  });
}
