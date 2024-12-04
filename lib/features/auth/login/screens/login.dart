import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:invsync/common/widgets/custom_button.dart';
import 'package:invsync/common/widgets/custom_textfield.dart';
import 'package:invsync/features/auth/login/services/login_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controllers for text fields
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Loading state for button
  bool isLoading = false;

  // Hive box reference
  late Box userBox;

  @override
  void initState() {
    super.initState();
    // Open Hive box
    userBox = Hive.box('user');
  }

  @override
  Widget build(BuildContext context) {
    // Retain statusbar settings
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    // Get theme for styling
    final theme = Theme.of(context).colorScheme;

    // Set status bar and navigation bar color
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: theme.surface,
      statusBarIconBrightness: theme.brightness,
      systemNavigationBarColor: theme.surface,
      systemNavigationBarIconBrightness: theme.brightness,
    ));

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: Text('InvSync',
                style: GoogleFonts.silkscreen(
                  fontSize: 20,
                  color: theme.primary,
                  fontWeight: FontWeight.bold,
                )),
          ),
          const SizedBox(height: 20),
          Center(
            child: Text('Login to your account to continue',
                style: TextStyle(
                  fontSize: 16,
                  color: theme.onSurface,
                )),
          ),
          const SizedBox(height: 20),

          // Email textfield
          CustomTextfield(
              width: 300,
              height: 50,
              hintText: "Email Address",
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              obscureText: false),

          const SizedBox(height: 10),

          // Password textfield
          CustomTextfield(
              width: 300,
              height: 50,
              hintText: "Password",
              controller: passwordController,
              keyboardType: TextInputType.visiblePassword,
              obscureText: true),

          const SizedBox(height: 10),

          // Login button
          CustomButton(
            width: 300,
            height: 50,
            bgColor: theme.primary,
            textColor: theme.onPrimary,
            text: "Sign in",
            onPressed: () async {
              final String email = emailController.text.trim();
              final String password = passwordController.text.trim();

              if (email.isEmpty || password.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please fill in all fields'),
                    backgroundColor: Colors.red,
                  ),
                );
              } else {
                setState(() {
                  isLoading = true;
                });

                // Call login service
                final response = await AuthService().login(email, password);

                if (response['status'] != 'error') {
                  final user = response['user'];

                  // Store user information in Hive
                  await userBox.put('id', user['_id']);
                  await userBox.put('name', user['name']);
                  await userBox.put('email', user['email']);
                  await userBox.put('image', user['image']);

                  // Navigate to dashboard
                  setState(() {
                    isLoading = false;
                  });

                  Navigator.pushReplacementNamed(context, '/dashboard');
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(response['message']),
                      backgroundColor: Colors.red,
                    ),
                  );

                  setState(() {
                    isLoading = false;
                  });
                }
              }
            },
            isLoading: isLoading,
          ),
        ],
      ),
    );
  }
}
