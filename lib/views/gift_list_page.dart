import 'package:flutter/material.dart';
import 'gift_details_page.dart';

class GiftListPage extends StatelessWidget {
  final String eventId;
  final String eventName;

  GiftListPage({required this.eventId, required this.eventName});

  @override
  Widget build(BuildContext context) {
    // Dummy gift data
    final gifts = [
      {'name': 'Gift 1', 'category': 'Category 1', 'status': 'Available'},
      {'name': 'Gift 2', 'category': 'Category 2', 'status': 'Pledged'},
    ];

    return Scaffold(
      appBar: AppBar(title: Text('Gifts for $eventName')),
      body: ListView.builder(
        itemCount: gifts.length,
        itemBuilder: (context, index) {
          final gift = gifts[index];
          return ListTile(
            title: Text(gift['name']!),
            subtitle: Text('Category: ${gift['category']}'),
            trailing: Text(gift['status']!),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GiftDetailsPage(
                    eventId: eventId,
                    giftId: null,
                    giftData: gift,
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GiftDetailsPage(
                eventId: eventId,
                giftId: null,
              ),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}