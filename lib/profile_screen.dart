import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final user = FirebaseAuth.instance.currentUser!;
  final _nameController = TextEditingController();
  String? photoUrl;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    if (doc.exists) {
      _nameController.text = doc['displayName'] ?? '';
      photoUrl = doc['photoUrl'];
      setState(() {});
    }
  }

  Future<void> _updateProfile() async {
    setState(() => isLoading = true);

    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      'displayName': _nameController.text.trim(),
      'photoUrl': photoUrl ?? '',
    });

    setState(() => isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully!')),
    );
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    final file = File(picked.path);
    final ref = FirebaseStorage.instance.ref().child('profile_pics/${user.uid}.jpg');
    await ref.putFile(file);
    photoUrl = await ref.getDownloadURL();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 60,
                backgroundImage: photoUrl != null && photoUrl!.isNotEmpty
                    ? NetworkImage(photoUrl!)
                    : const AssetImage('assets/default_avatar.png') as ImageProvider,
                child: const Align(
                  alignment: Alignment.bottomRight,
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.teal,
                    child: Icon(Icons.camera_alt, color: Colors.white),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Display Name'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateProfile,
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
