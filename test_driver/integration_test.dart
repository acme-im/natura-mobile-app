import 'dart:io';

import 'package:integration_test/integration_test_driver.dart';

Future<void> main() async {
  const adbPath = '/home/robert/Android/Sdk/platform-tools/adb'; // TODO
  await Process.run(adbPath, ['shell', 'pm', 'grant', 'im.acme.natura', 'android.permission.RECORD_AUDIO']);

  // this should come at the end
  await integrationDriver();
}
