import 'package:flutter/foundation.dart';

bool soportaSegundoPlanoAvisos() =>
    !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
