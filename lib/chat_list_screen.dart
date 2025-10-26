import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser!;
    final firestore = FirebaseFirestore.instance;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestore.collection('chats').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final chatDocs = snapshot.data!.docs;

          // Get chat documents that include the current user’s email in their ID
          final userChats = chatDocs.where((doc) {
            final chatId = doc.id;
            return chatId.contains(currentUser.email!);
          }).toList();

          if (userChats.isEmpty) {
            return const Center(child: Text('No chats yet'));
          }

          return ListView.builder(
            itemCount: userChats.length,
            itemBuilder: (context, index) {
              final chatId = userChats[index].id;
              final otherUserEmail = chatId
                  .split('_')
                  .firstWhere((email) => email != currentUser.email);

              return StreamBuilder<QuerySnapshot>(
                stream: firestore
                    .collection('chats')
                    .doc(chatId)
                    .collection('messages')
                    .orderBy('timestamp', descending: true)
                    .limit(1)
                    .snapshots(),
                builder: (context, messageSnapshot) {
                  if (!messageSnapshot.hasData) return const SizedBox.shrink();

                  final lastMsgDocs = messageSnapshot.data!.docs;
                  String lastMessage = lastMsgDocs.isNotEmpty
                      ? lastMsgDocs.first['text']
                      : 'No messages yet';

                  return ListTile(
                    title: Text(otherUserEmail),
                    subtitle: Text(
                      lastMessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatScreen(receiverEmail: otherUserEmail),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
