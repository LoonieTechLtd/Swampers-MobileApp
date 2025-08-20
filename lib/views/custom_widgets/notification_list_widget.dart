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
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: notification.read ? Colors.grey.shade50 : Colors.blue.shade50,
        border: Border.all(
          color:
              notification.read ? Colors.grey.shade200 : Colors.blue.shade200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status indicator
                Container(
                  width: 12,
                  height: 12,
                  margin: const EdgeInsets.only(top: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        notification.read ? Colors.grey.shade400 : Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),

                // Avatar with better styling
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade300, width: 2),
                  ),
                  child: CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.blue.shade100,
                    child: Icon(
                      Icons.notifications,
                      color: Colors.blue.shade700,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: CustomTextStyles.h4.copyWith(
                                fontWeight:
                                    notification.read
                                        ? FontWeight.w500
                                        : FontWeight.w600,
                                color:
                                    notification.read
                                        ? Colors.grey.shade700
                                        : Colors.black87,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (!notification.read)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'NEW',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        notification.body.toString(),
                        style: CustomTextStyles.description.copyWith(
                          color:
                              notification.read
                                  ? Colors.grey.shade600
                                  : Colors.grey.shade700,
                          height: 1.4,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Action button
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: notificationToggle,
                  icon: Icon(
                    notification.read
                        ? Icons.mark_email_unread
                        : Icons.mark_email_read,
                    size: 16,
                  ),
                  label: Text(
                    notification.read ? "Mark as Unread" : "Mark as Read",
                    style: TextStyle(fontSize: 12),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor:
                        notification.read ? Colors.orange : Colors.green,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
