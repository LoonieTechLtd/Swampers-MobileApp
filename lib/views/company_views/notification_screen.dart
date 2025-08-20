import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swamper_solution/consts/custom_text_styles.dart';
import 'package:swamper_solution/controllers/notification_controller.dart';
import 'package:swamper_solution/providers/all_providers.dart';
import 'package:swamper_solution/core/services/notificiation_services.dart';
import 'package:swamper_solution/views/custom_widgets/notification_list_widget.dart';

class NotificationScreen extends ConsumerWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationAsnc = ref.watch(getUserNotifications);
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          NotificiationServices.showNotification(
            title: "Test Notification",
            body: "Body of the test notification and other details",
          );
        },
        icon: Icon(Icons.notifications_active_outlined),
        label: Text("Test"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: Text("Notifications", style: CustomTextStyles.title),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Container(height: 1, color: Colors.grey.shade200),
        ),
      ),
      body: SafeArea(
        child: notificationAsnc.when(
          data: (notification) {
            if (notification.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.notifications_none,
                      size: 80,
                      color: Colors.grey.shade400,
                    ),
                    SizedBox(height: 16),
                    Text(
                      "No Notifications",
                      style: CustomTextStyles.h3.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "You're all caught up!",
                      style: CustomTextStyles.description.copyWith(
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              );
            }
            return ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 8),
              itemCount: notification.length,
              itemBuilder: (context, index) {
                final noti = notification[index];
                return NotificationListWidget(
                  notification: noti,
                  notificationToggle: () {
                    NotificationController().toggleNotificationReadStatus(
                      noti.notificationId,
                    );
                  },
                );
              },
            );
          },
          error: (error, stack) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 60,
                    color: Colors.red.shade300,
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Something went wrong",
                    style: CustomTextStyles.h4.copyWith(
                      color: Colors.red.shade600,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Error: $error",
                    style: CustomTextStyles.description,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          },
          loading: () {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    "Loading notifications...",
                    style: CustomTextStyles.description.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
