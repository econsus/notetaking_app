// lib/controllers/notification_controller.dart
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationController {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> requestPermission() async {
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else {
      print('User declined or has not accepted permission');
    }
  }

  void setupFCM() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Message received while in foreground: ${message.notification?.title}');
      // Handle the foreground notification
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Message clicked! ${message.notification?.title}');
      // Handle the notification clicked when the app is opened
    });

    // For background and terminated state
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    print('Handling a background message: ${message.messageId}');
    // Handle the background message
  }
}
