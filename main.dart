import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:project/controllers/notification_controller.dart';
import 'package:project/views/login_page.dart';
import 'package:project/views/home_page.dart';
import 'package:project/views/event_list_page.dart';
import 'package:project/views/gift_list_page.dart';
import 'package:project/views/create_event_page.dart';
import 'package:project/views/edit_event_page.dart';
import 'package:project/views/sign_up.dart';
import 'package:project/views/gift_details_page.dart';
import 'package:project/views/profile.dart';
import 'package:project/views/notification_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(HedieatyApp());
}

class HedieatyApp extends StatefulWidget {
  @override
  _HedieatyAppState createState() => _HedieatyAppState();
}

class _HedieatyAppState extends State<HedieatyApp> {
  final NotificationController _notificationController = NotificationController();
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
  OverlayEntry? _currentNotification;

  @override
  void initState() {
    super.initState();
    _initializeLocalNotifications();
    _listenForNotifications();
  }

  // Initialize local notifications
  void _initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);

    await _localNotificationsPlugin.initialize(
      initializationSettings,
    );
  }

  // Listen for notifications
  void _listenForNotifications() {
    try {
      _notificationController.listenForNotifications((message) {
        if (message.isNotEmpty) {
          _showInAppNotification(message);
          _showPhoneNotification(message);
        }
      });
    } catch (e) {
      debugPrint('Error listening for notifications: $e');
    }
  }

  // Display in-app notification
  void _showInAppNotification(String message) {
    _currentNotification?.remove();

    _currentNotification = OverlayEntry(
      builder: (context) => NotificationScreen(message: message),
    );

    _navigatorKey.currentState?.overlay?.insert(_currentNotification!);

    Future.delayed(const Duration(seconds: 4), () {
      _currentNotification?.remove();
      _currentNotification = null;
    });
  }

  // Display phone notification
  void _showPhoneNotification(String message) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'pledge_notifications', // Channel ID
      'Pledge Notifications', // Channel Name
      channelDescription: 'Notifications for gift pledges',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const NotificationDetails platformDetails = NotificationDetails(android: androidDetails);

    await _localNotificationsPlugin.show(
      0, // Notification ID
      'New Notification', // Title
      message, // Body
      platformDetails,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Hedieaty',
      theme: ThemeData(primarySwatch: Colors.purple),
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginPage(),
        '/signup': (context) => SignUpPage(),
      },
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/home':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => HomePage(currentUserId: args['currentUserId']),
            );
          case '/eventListPage':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => EventListPage(
                friendName: args['friendName'],
                currentUserId: args['currentUserId'],
              ),
            );
          case '/createEventPage':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => CreateEventPage(currentUserId: args['currentUserId']),
            );
          case '/giftListPage':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => GiftListPage(
                userId: args['userId'],
                eventId: args['eventId'],
                eventName: args['eventName'],
              ),
            );
          case '/giftDetailsPage':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => GiftDetailsPage(
                userId: args['userId'],
                eventId: args['eventId'],
                gift: args['gift'],
              ),
            );
          case '/profilePage':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => ProfilePage(
                currentUserId: args['currentUserId'],
              ),
            );
          default:
            return null;
        }
      },
    );
  }
}
