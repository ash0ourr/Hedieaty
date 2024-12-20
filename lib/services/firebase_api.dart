// import 'dart:convert';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:http/http.dart' as http;
//
// Future<void> handleBackgroundMessage(RemoteMessage message) async {
//   print('Background message received: ${message.notification?.title}');
// }
//
// class FirebaseAPI {
//   final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
//   late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
//   late AndroidNotificationChannel channel;
//
//   bool _isFlutterLocalNotificationsInitialized = false;
//
//   // Initialize Firebase Messaging and Local Notifications
//   Future<void> initNotification(String userId) async {
//     // Request permission for notifications
//     await _firebaseMessaging.requestPermission();
//
//     // Get FCM Token and save to Realtime Database
//     final fcmToken = await _firebaseMessaging.getToken();
//     print('FCM Token: $fcmToken');
//     if (fcmToken != null) {
//       await _saveTokenToDatabase(userId, fcmToken);
//     }
//
//     // Setup Local Notifications
//     await _setupFlutterNotifications();
//     _initPushNotificationListeners();
//   }
//
//   Future<void> _saveTokenToDatabase(String userId, String fcmToken) async {
//     final databaseRef = FirebaseDatabase.instance.ref('users/$userId');
//     await databaseRef.update({'fcmToken': fcmToken});
//   }
//
//   Future<void> _setupFlutterNotifications() async {
//     if (_isFlutterLocalNotificationsInitialized) return;
//
//     flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
//     channel = const AndroidNotificationChannel(
//       'high_importance_channel',
//       'High Importance Notifications',
//       description: 'This channel is used for important notifications.',
//       importance: Importance.high,
//     );
//
//     const initializationSettings = InitializationSettings(
//       android: AndroidInitializationSettings('@mipmap/ic_launcher'),
//     );
//     await flutterLocalNotificationsPlugin.initialize(initializationSettings);
//
//     await flutterLocalNotificationsPlugin
//         .resolvePlatformSpecificImplementation<
//         AndroidFlutterLocalNotificationsPlugin>()
//         ?.createNotificationChannel(channel);
//
//     await _firebaseMessaging.setForegroundNotificationPresentationOptions(
//       alert: true,
//       badge: true,
//       sound: true,
//     );
//
//     _isFlutterLocalNotificationsInitialized = true;
//   }
//
//   void _initPushNotificationListeners() {
//     // Handle messages when the app is in the foreground
//     FirebaseMessaging.onMessage.listen((message) {
//       _showNotification(message);
//     });
//
//     // Handle messages when the app is opened via notification
//     FirebaseMessaging.onMessageOpenedApp.listen((message) {
//       print('Notification Clicked: ${message.notification?.title}');
//     });
//
//     // Handle background messages
//     FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
//   }
//
//   void _showNotification(RemoteMessage message) {
//     final notification = message.notification;
//     final android = message.notification?.android;
//
//     if (notification != null && android != null && !kIsWeb) {
//       flutterLocalNotificationsPlugin.show(
//         notification.hashCode,
//         notification.title,
//         notification.body,
//         NotificationDetails(
//           android: AndroidNotificationDetails(
//             channel.id,
//             channel.name,
//             channelDescription: channel.description,
//             icon: '@mipmap/ic_launcher',
//           ),
//         ),
//       );
//     }
//   }
//
//   // Send Notification to User via FCM HTTP API
//   Future<void> sendNotification({
//     required String fcmToken,
//     required String title,
//     required String body,
//   }) async {
//     const String serverKey = 'YOUR_SERVER_KEY_HERE'; // Replace with your FCM server key
//     const String url = 'https://fcm.googleapis.com/fcm/send';
//
//     final response = await http.post(
//       Uri.parse(url),
//       headers: {
//         'Content-Type': 'application/json',
//         'Authorization': 'key=$serverKey',
//       },
//       body: jsonEncode({
//         'to': fcmToken,
//         'notification': {
//           'title': title,
//           'body': body,
//           'sound': 'default',
//         },
//         'priority': 'high',
//       }),
//     );
//
//     if (response.statusCode == 200) {
//       print('Notification sent successfully');
//     } else {
//       print('Failed to send notification: ${response.body}');
//     }
//   }
// }
