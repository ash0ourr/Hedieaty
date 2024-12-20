// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
//
// class NotificationService {
//   final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//   FlutterLocalNotificationsPlugin();
//
//   NotificationService() {
//     _initNotifications();
//   }
//
//   void _initNotifications() {
//     const AndroidInitializationSettings initializationSettingsAndroid =
//     AndroidInitializationSettings('@mipmap/ic_launcher');
//
//     const InitializationSettings initializationSettings =
//     InitializationSettings(android: initializationSettingsAndroid);
//
//     flutterLocalNotificationsPlugin.initialize(initializationSettings);
//   }
//
//   Future<void> showLocalNotification({
//     required int id,
//     required String title,
//     required String body,
//   }) async {
//     const AndroidNotificationDetails androidDetails =
//     AndroidNotificationDetails('channel_id', 'channel_name',
//         channelDescription: 'Notification channel for app',
//         importance: Importance.high,
//         priority: Priority.high);
//
//     const NotificationDetails platformChannelSpecifics =
//     NotificationDetails(android: androidDetails);
//
//     await flutterLocalNotificationsPlugin.show(
//       id,
//       title,
//       body,
//       platformChannelSpecifics,
//     );
//   }
//
// }
