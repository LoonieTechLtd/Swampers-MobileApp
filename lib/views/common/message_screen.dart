import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:random_string/random_string.dart';
import 'package:swamper_solution/consts/app_colors.dart';
import 'package:swamper_solution/controllers/message_controller.dart';
import 'package:swamper_solution/models/message_model.dart';
import 'package:swamper_solution/providers/all_providers.dart';
import 'package:swamper_solution/views/custom_widgets/chat_header.dart';
import 'package:swamper_solution/views/custom_widgets/chat_input_field.dart';

class MessageScreen extends ConsumerWidget {
  MessageScreen({super.key});
  final TextEditingController messageController = TextEditingController();
  final ValueNotifier<bool> isButtonEnabled = ValueNotifier(false);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messageAsnc = ref.watch(getUserMessage);
    messageController.addListener(() {
      isButtonEnabled.value = messageController.text.trim().isNotEmpty;
    });

    return Scaffold(
      appBar: AppBar(
        title: Text("Messages"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const ChatHeader(),
            Expanded(
              child: messageAsnc.when(
                data: (messages) {
                  if (messages.isEmpty) {
                    return const Center(child: Text('No messages yet'));
                  }

                  // Sort messages by date
                  messages.sort((a, b) => a.sendAt.compareTo(b.sendAt));

                  return ListView.builder(
                    itemCount: messages.length,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final bool isCurrentUser =
                          message.senderId ==
                          FirebaseAuth.instance.currentUser!.uid;
                      final bool shouldShowDate =
                          index == 0 ||
                          !_isSameDay(
                            messages[index - 1].sendAt,
                            message.sendAt,
                          );

                      return Column(
                        children: [
                          if (shouldShowDate)
                            _DateDivider(date: message.sendAt),
                          MessageBubble(
                            message: message,
                            isCurrentUser: isCurrentUser,
                          ),
                        ],
                      );
                    },
                  );
                },
                error: (error, stack) {
                  return Center(child: Text("Error Loading Messages"));
                },
                loading: () {
                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ),
            ValueListenableBuilder<bool>(
              valueListenable: isButtonEnabled,
              builder: (context, enabled, child) {
                return ChatInputField(
                  controller: messageController,
                  isEnabled: enabled,
                  primaryColor: AppColors().primaryColor,
                  onSendPressed: () async {
                    final messageId = randomAlphaNumeric(10);
                    final swamperUid = "UID123";
                    MessageModel message = MessageModel(
                      messageId: messageId,
                      message: messageController.text,
                      senderId: FirebaseAuth.instance.currentUser!.uid,
                      receiverId: swamperUid,
                      isImage: false,
                      sendAt: DateTime.now(),
                    );
                    await MessageController().sendMessagetoSwamper(
                      message,
                      messageId,
                    );
                    messageController.clear();
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

class _DateDivider extends StatelessWidget {
  final DateTime date;

  const _DateDivider({required this.date});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: const Color.fromARGB(23, 0, 0, 0),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _formatDate(date),
            style: const TextStyle(color: Colors.black54, fontSize: 12),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(date.year, date.month, date.day);

    if (messageDate == today) {
      return 'Today';
    } else if (messageDate == yesterday) {
      return 'Yesterday';
    } else {
      return DateFormat('MMM d, y').format(date);
    }
  }
}

class MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isCurrentUser;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isCurrentUser,
  });

  @override
  Widget build(BuildContext context) {
    final time = DateFormat('HH:mm').format(message.sendAt);

    if (isCurrentUser) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.6,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: const Color.fromARGB(255, 232, 234, 253),
                  ),
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    message.message,
                    style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
                      height: 1.2,
                      fontSize: 16,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 2, right: 4),
                  child: Text(
                    time,
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          const CircleAvatar(
            backgroundColor: Colors.blue,
            child: Icon(Icons.headset_mic_outlined, color: Colors.white),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        spreadRadius: 1,
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    message.message,
                    style: const TextStyle(
                      color: Colors.black,
                      height: 1.2,
                      fontSize: 16,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 2, left: 4),
                  child: Text(
                    time,
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
