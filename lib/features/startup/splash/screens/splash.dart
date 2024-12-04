import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Hide status bar and enable immersive mode
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    // Get theme for styling
    final theme = Theme.of(context).colorScheme;

    // Fetch user data from Hive box after a delay
    Future.delayed(const Duration(seconds: 2), () async {
      var userBox = await Hive.openBox('user'); // Open the Hive box

      // Check if user data exists
      final userId = userBox.get('id');
      if (userId != null) {
        // If user data exists, navigate to dashboard
        Navigator.pushReplacementNamed(context, '/dashboard');
      } else {
        // If no user data, navigate to login screen
        Navigator.pushReplacementNamed(context, '/login');
      }
    });

    return Scaffold(
      backgroundColor: theme.primary,
      body: Center(
        child: Text(
          'invsync',
          style: GoogleFonts.silkscreen(
            textStyle: TextStyle(
              fontSize: 30,
              color: theme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
