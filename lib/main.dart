import 'package:flutter/material.dart';

import 'features/startup/splash/screens/splash.dart';

void main(){
  runApp(const InvSyncApp());
}


class InvSyncApp extends StatelessWidget {
  const InvSyncApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'InvSync',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SplashScreen(),
    );
  }
}