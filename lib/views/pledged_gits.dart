import 'package:flutter/material.dart';
import 'package:project/controllers/gift_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyPledgedGiftsPage extends StatefulWidget {
  final String userId;

  const MyPledgedGiftsPage({Key? key, required this.userId}) : super(key: key);

  @override
  State<MyPledgedGiftsPage> createState() => _MyPledgedGiftsPageState();
}

class _MyPledgedGiftsPageState extends State<MyPledgedGiftsPage> with SingleTickerProviderStateMixin {
  final GiftController _giftController = GiftController();

  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeInAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _removePledgedGift(String giftId, String eventId) async {
    try {
      // Reset the gift's state to its default
      final updatedFields = {
        'pledged': false,
        'pledgerId': null,
      };

      // Update the gift in Firestore
      await _giftController.updateGift(widget.userId, eventId, giftId, updatedFields);

      // Remove the gift from the pledged collection
      await _giftController.removePledgedGift(widget.userId, giftId);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gift removed from pledged gifts.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error removing gift: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Pledged Gifts'),
        backgroundColor: Colors.pinkAccent,
      ),
      body: FadeTransition(
        opacity: _fadeInAnimation,
        child: StreamBuilder<List<Map<String, dynamic>>>(
          stream: _giftController.fetchPledgedGifts(widget.userId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No pledged gifts found.'));
            }

            final pledgedGifts = snapshot.data!;
            return ListView.builder(
              itemCount: pledgedGifts.length,
              itemBuilder: (context, index) {
                final gift = pledgedGifts[index];
                final pledgedAt = (gift['pledgedAt'] as Timestamp).toDate();
                final giftId = gift['giftId'];
                final eventId = gift['eventId'];

                return Card(
                  color: Colors.green[100],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: ListTile(
                    title: Text(
                      gift['giftName'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Friend: ${gift['friendId']}\nPledged At: ${pledgedAt.toLocal()}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _removePledgedGift(giftId, eventId),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
