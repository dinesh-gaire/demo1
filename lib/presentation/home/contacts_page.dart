import 'package:flutter/material.dart';
import 'package:offnet/data/objectbox.dart';
import 'package:offnet/data/models.dart';
import 'package:go_router/go_router.dart';
import 'package:offnet/objectbox.g.dart';
import 'dart:io';

class ContactsPage extends StatelessWidget {
  final ObjectBox objectBox;

  const ContactsPage({Key? key, required this.objectBox}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final otherUsers = objectBox.otherUserBox.getAll();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
      ),
      body: ListView.builder(
        itemCount: otherUsers.length,
        itemBuilder: (context, index) {
          final user = otherUsers[index];
          final messages = objectBox.messageBox
              .query(Message_.otherUser.equals(user.id))
              .order(Message_.timestamp, flags: Order.descending)
              .build()
              .find();

          final lastMessage = messages.isNotEmpty ? messages.first : null;
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: user.pathToImage != null
                  ? FileImage(File(user.pathToImage!))
                  : null,
              child: user.pathToImage == null
                  ? Text(user.name[0].toUpperCase())
                  : null,
            ),
            title: Text(user.name),
            subtitle: Text(
              lastMessage?.content ?? 'No messages yet',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: lastMessage != null
                ? Text(
                    _formatMessageTime(lastMessage.timestamp),
                    style: Theme.of(context).textTheme.bodySmall,
                  )
                : null,
            onTap: () => context.go('/chat/${user.uniqueId}'),
          );
        },
      ),
    );
  }

  String _formatMessageTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }
}
