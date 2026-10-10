import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('el manifiesto principal de Android declara el permiso de red', () {
    final manifiesto = File('android/app/src/main/AndroidManifest.xml')
        .readAsStringSync();

    expect(manifiesto, contains('android.permission.INTERNET'));
  });
}
