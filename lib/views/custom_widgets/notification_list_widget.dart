import 'package:flutter/material.dart';
import 'package:swamper_solution/consts/custom_text_styles.dart';
import 'package:swamper_solution/models/notification_model.dart';

class NotificationListWidget extends StatelessWidget {
  final NotificationModel notification;

  final VoidCallback notificationToggle;
  const NotificationListWidget({
    super.key,
    required this.notification,
    required this.notificationToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.black12,
      ),
      child: Stack(
        children: [
          /// Main Row: Avatar + Info
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(radius: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: CustomTextStyles.h4,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.body.toString(),
                      style: CustomTextStyles.description.copyWith(
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          Positioned(
            bottom: -10,
            right: 0,
            child: TextButton(
              onPressed: notificationToggle,
              child:
                  notification.read
                      ? Text("Mark as Unread")
                      : Text("Mark as Read"),
            ),
          ),
        ],
      ),
    );
  }
}
