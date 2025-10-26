import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'users_screen.dart';
import 'chat_list_screen.dart';
import 'profile_screen.dart';
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lingua Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Welcome, ${user?.email ?? "User"}!'),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.people),
              label: const Text('View Users'),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const UsersScreen()));
              },
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              icon: const Icon(Icons.chat),
              label: const Text('View Chats'),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatListScreen()));
              },
            ),

            ElevatedButton.icon(
              icon: const Icon(Icons.person),
              label: const Text('Edit Profile'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
              },
            ),

          ],
        ),
      ),
    );
  }
}
