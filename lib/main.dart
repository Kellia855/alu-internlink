import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:alu_internlink/app.dart';
import 'package:alu_internlink/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const alu_InternLink());
}
