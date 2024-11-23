import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat/widgets/message_bubble.dart';

class ChatMessage extends StatelessWidget {
  const ChatMessage({super.key});

  @override
  Widget build(BuildContext context) {
    final authenticatedUser = FirebaseAuth.instance.currentUser!;

    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('chat')
            .orderBy('createAt', descending: false)
            .snapshots(),
        builder: (context, chatSnapshop) {
          if (chatSnapshop.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!chatSnapshop.hasData || chatSnapshop.data!.docs.isEmpty) {
            return const Center(
              child: Text('No Messages found.'),
            );
          }

          if (chatSnapshop.hasError) {
            return const Center(
              child: Text('Somethis went wrong...'),
            );
          }

          final loadedMessage = chatSnapshop.data!.docs;

          return ListView.builder(
              padding: const EdgeInsets.only(bottom: 40, left: 13, right: 13),
              reverse: true,
              itemCount: loadedMessage.length,
              itemBuilder: (ctx, index) {
                final chatMessage = loadedMessage[index].data();

                final nextChatMessage = index + 1 < loadedMessage.length
                    ? loadedMessage[index + 1].data()
                    : null;

                final currentMessageUserId = chatMessage['userId'];
                final nextMessageUserId =
                    nextChatMessage != null ? nextChatMessage['userId'] : null;

                final nextUserIsSame =
                    nextMessageUserId == currentMessageUserId;

                if (nextUserIsSame) {
                  return MessageBubble.next(
                      message: chatMessage['text'],
                      isMe: authenticatedUser.uid == currentMessageUserId);
                } else {
                  return MessageBubble.first(
                      userImage: null,
                      username: chatMessage['username'],
                      message: chatMessage['text'],
                      isMe: authenticatedUser.uid == currentMessageUserId);
                }
              });
        });
  }
}
