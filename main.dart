import 'package:flutter/material.dart';
import 'package:project/views/login_page.dart';
import 'package:project/views/home_page.dart';
import 'package:project/views/event_list_page.dart';
import 'package:project/views/gift_list_page.dart';
import 'package:project/views/gift_details_page.dart';

import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(HedieatyApp());
}

class HedieatyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hedieaty',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginPage(),
        '/home': (context) => HomePage(),
        '/events': (context) => EventListPage(),
        // Dynamic routes will require MaterialPageRoute in the calling widget.
      },
      onGenerateRoute: (settings) {
        // Handle routes with parameters like GiftListPage and GiftDetailsPage.
        if (settings.name == '/gifts') {
          final args = settings.arguments as Map<String, String>;
          return MaterialPageRoute(
            builder: (context) => GiftListPage(
              eventId: args['eventId']!,
              eventName: args['eventName']!,
            ),
          );
        } else if (settings.name == '/gift-details') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => GiftDetailsPage(
              eventId: args['eventId']!,
              giftId: args['giftId'],
              giftData: args['giftData'],
            ),
          );
        }
        return null; // Return null if the route is not found.
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
