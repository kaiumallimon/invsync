import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:invsync/common/widgets/custom_button.dart';
import 'package:invsync/features/auth/login/services/login_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // get theme
    final theme = Theme.of(context).colorScheme;
    return FutureBuilder<Map<String, dynamic>>(
        future: getUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.data!['id'] != null) {
              return Padding(
                padding: const EdgeInsets.all(25),
                child: Column(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          snapshot.data!['image'] != null
                              ? Center(
                                  child: CircleAvatar(
                                    radius: 50,
                                    backgroundImage:
                                        NetworkImage(snapshot.data!['image']),
                                  ),
                                )
                              : const Center(
                                  child: CircleAvatar(
                                    radius: 50,
                                    child: Icon(
                                      Icons.person,
                                      size: 50,
                                    ),
                                  ),
                                ),
                          const SizedBox(height: 20),
                          Text(
                            snapshot.data!['name'],
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            snapshot.data!['email'],
                            style: TextStyle(
                              fontSize: 16,
                              color: theme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Logout button
                    CustomButton(
                        width: 300,
                        height: 50,
                        text: "Log out",
                        bgColor: theme.error,
                        textColor: theme.onError,
                        onPressed: () async {
                          await AuthService().logout(context);
                        },
                        isLoading: false)
                  ],
                ),
              );
            } else {
              return const Center(
                child: Text('No user data found'),
              );
            }
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        });
  }

  Future<Map<String, dynamic>> getUserData() async {
    // Fetch user data from Hive box after a delay
    var userBox = await Hive.openBox('user'); // Open the Hive box

    // Check if user data exists

    final userId = userBox.get('id');
    final name = userBox.get('name');
    final email = userBox.get('email');
    final image = userBox.get('image');

    if (userId != null) {
      // If user data exists, navigate to dashboard
      return {'id': userId, 'name': name, 'email': email, 'image': image};
    } else {
      // If no user data, navigate to login screen
      return {'id': null, 'name': null, 'email': null, 'image': null};
    }
  }
}
