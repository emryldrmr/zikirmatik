import 'package:flutter/services.dart';

/// The app is always upright: it never turns sideways or upside down
/// (spec 0012, CB-1). The manifest holds the same lock for the first frame
/// (CB-2).
Future<void> lockPortrait() =>
    SystemChrome.setPreferredOrientations(const [DeviceOrientation.portraitUp]);
