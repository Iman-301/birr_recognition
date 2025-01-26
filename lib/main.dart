import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'currency_recognizer.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
  runApp(MaterialApp(
    home: CurrencyRecognizer(),
    debugShowCheckedModeBanner: false,
  ));
}