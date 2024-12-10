import 'package:flutter/material.dart';

class EventListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Event List')),
      body: ListView.builder(
        itemCount: 10, // Example data
        itemBuilder: (context, index) {
          return ListTile(
            title: Text('Event ${index + 1}'),
            subtitle: Text('Details of Event ${index + 1}'),
            onTap: () {
              // TODO: Navigate to Gift List
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to Create Event Page
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
