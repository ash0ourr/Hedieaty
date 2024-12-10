import 'package:flutter/material.dart';
import 'package:project/views/event_list_page.dart';

class HomePage extends StatelessWidget {
  Future<void> _logout(BuildContext context) async {
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hedieaty - Home'),
        actions: [
          IconButton(icon: Icon(Icons.logout), onPressed: () => _logout(context)),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => EventListPage()));
              },
              child: Text('View Events'),
            ),
            ElevatedButton(
              onPressed: () {
                // TODO: Navigate to Friends List
              },
              child: Text('View Friends'),
            ),
          ],
        ),
      ),
    );
  }
}