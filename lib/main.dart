import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fashion_ecommerce/app/app.dart';
import 'package:fashion_ecommerce/firebase_options.dart';
import 'package:fashion_ecommerce/core/database/seed_data.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with generated options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Auto seed data jika Firestore masih kosong
  try {
    await SeedData.seedIfEmpty();
  } catch (e) {
    print('Seed info: $e');
  }

  runApp(const App());
}
