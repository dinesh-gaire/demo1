import 'package:flutter/material.dart';
import 'package:offnet/data/objectbox.dart';
import 'package:offnet/data/models.dart';
import 'dart:io';
import 'package:go_router/go_router.dart';

import 'package:offnet/objectbox.g.dart';

class ChatPage extends StatefulWidget {
  final ObjectBox objectBox;
  final String otherUserUniqueId;

  const ChatPage(
      {Key? key, required this.objectBox, required this.otherUserUniqueId})
      : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  late OtherUserEntity otherUser;

  @override
  void initState() {
    super.initState();
    otherUser = widget.objectBox.otherUserBox
        .query(OtherUserEntity_.uniqueId.equals(widget.otherUserUniqueId))
        .build()
        .findFirst()!;
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    final message = Message(
      content: _messageController.text,
      isFromMe: true,
      timestamp: DateTime.now(),
    );
    message.otherUser.target = otherUser;
    widget.objectBox.messageBox.put(message);
    _messageController.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final messages = widget.objectBox.messageBox
        .query(Message_.otherUser.equals(otherUser.id))
        .build()
        .find();

    return WillPopScope(
      onWillPop: () async {
        context.go('/');
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              CircleAvatar(
                backgroundImage: otherUser.pathToImage != null
                    ? FileImage(File(otherUser.pathToImage!))
                    : null,
                child: otherUser.pathToImage == null
                    ? Text(otherUser.name[0].toUpperCase())
                    : null,
              ),
              const SizedBox(width: 10),
              Text(otherUser.name),
            ],
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                reverse: true,
                padding: const EdgeInsets.all(16),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[messages.length - 1 - index];
                  return MessageBubble(message: message);
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: 'Type a message...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(24)),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _sendMessage,
                    icon: const Icon(Icons.send),
                    style: IconButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final Message message;

  const MessageBubble({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment:
          message.isFromMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: message.isFromMe
              ? Theme.of(context).primaryColor
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          message.content,
          style: TextStyle(
            color: message.isFromMe ? Colors.white : null,
          ),
        ),
      ),
    );
  }
}
