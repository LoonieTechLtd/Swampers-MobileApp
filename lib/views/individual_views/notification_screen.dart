import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swamper_solution/consts/custom_text_styles.dart';
import 'package:swamper_solution/controllers/notification_controller.dart';
import 'package:swamper_solution/providers/all_providers.dart';
import 'package:swamper_solution/views/custom_widgets/notification_list_widget.dart';

class NotificationScreen extends ConsumerWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationAsnc = ref.watch(getUserNotifications);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Notifications", style: CustomTextStyles.title),
      ),
      body: SafeArea(
        child: notificationAsnc.when(
          data: (notification) {
            if (notification.isEmpty) {
              return Center(child: Text("No Notification Available"));
            }
            return ListView.builder(
              itemCount: notification.length,
              itemBuilder: (context, index) {
                final notif = notification[index];
                debugPrint("$notif");
                return NotificationListWidget(
                  notification: notif,
                  notificationToggle: () {
                    NotificationController().toggleNotificationReadStatus(
                     notif.notificationId
                    );
                  },
                );
              },
            );
          },
          error: (error, stack) {
            return Center(child: Text("Error fetching Notification $error"));
          },
          loading: () {
            return Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}
