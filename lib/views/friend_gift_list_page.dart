import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:project/controllers/gift_controller.dart';
import 'package:project/controllers/notification_controller.dart';
import 'package:project/models/GiftModel.dart';

class FriendGiftListPage extends StatefulWidget {
  final String currentUserId;
  final String eventId;
  final String friendId; // User1 (Event Owner)
  final String friendName;
  final String eventName;

  const FriendGiftListPage({
    Key? key,
    required this.currentUserId,
    required this.eventId,
    required this.friendId, // Initialize user1 (owner of the event)
    required this.friendName,
    required this.eventName,
  }) : super(key: key);

  @override
  State<FriendGiftListPage> createState() => _FriendGiftListPageState();
}

class _FriendGiftListPageState extends State<FriendGiftListPage>
    with SingleTickerProviderStateMixin {
  final GiftController _giftController = GiftController();
  final NotificationController _notificationController =
  NotificationController(); // Custom controller
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
  FlutterLocalNotificationsPlugin(); // For local notifications
  String _sortBy = 'name';

  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;

  @override
  void initState() {
    super.initState();
    _initializeNotifications(); // Initialize local notifications

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
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

  void _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);

    await _localNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null) {
          debugPrint('Notification payload: ${response.payload}');
        }
      },
    );
  }

  Future<void> _showNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'pledge_channel',
      'Pledge Notifications',
      channelDescription: 'Notifications about pledges on gifts',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'ticker',
    );
    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    await _localNotificationsPlugin.show(
      0, // Notification ID
      title,
      body,
      platformChannelSpecifics,
    );
  }

  Future<void> _pledgeGift(GiftModel gift) async {
    final updatedGift = {
      'pledged': true,
      'pledgerId': widget.currentUserId,
    };

    await _giftController.updateGift(
      widget.friendId,
      widget.eventId,
      gift.id,
      updatedGift,
    );

    final pledgerName = await _giftController.fetchUserName(widget.currentUserId);

    await _giftController.logPledgedGift(
      widget.currentUserId,
      widget.friendId,
      widget.friendName,
      gift,
    );

    await _notificationController.addPledgeNotification(
      eventOwnerId: widget.friendId,
      pledgerName: pledgerName,
      giftName: gift.name,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${gift.name} pledged!')),
    );

    await _showNotification(
      'New Pledge!',
      '${widget.currentUserId} pledged "${gift.name}" for ${widget.friendName}.',
    );
  }


  Future<void> _markGiftAsPurchased(GiftModel gift) async {
    final updatedGift = {
      'purchased': true,
    };

    await _giftController.updateGift(
      widget.friendId,
      widget.eventId,
      gift.id,
      updatedGift,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${gift.name} purchased!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gifts for ${widget.eventName}'),
        backgroundColor: Colors.pinkAccent,
      ),
      body: FadeTransition(
        opacity: _fadeInAnimation,
        child: Column(
          children: [
            // Sort Dropdown
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: DropdownButtonFormField<String>(
                value: _sortBy,
                onChanged: (value) {
                  setState(() {
                    _sortBy = value!;
                  });
                },
                items: const [
                  DropdownMenuItem(value: 'name', child: Text('Sort by Name')),
                  DropdownMenuItem(value: 'date', child: Text('Sort by Date')),
                ],
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  labelText: 'Sort Options',
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Gift List
            Expanded(
              child: StreamBuilder<List<GiftModel>>(
                stream: _giftController.fetchGifts(widget.eventId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No gifts found.'));
                  }

                  final gifts = snapshot.data!;
                  gifts.sort((a, b) {
                    if (_sortBy == 'name') {
                      return a.name.compareTo(b.name);
                    } else if (_sortBy == 'date') {
                      return a.date.compareTo(b.date);
                    }
                    return 0;
                  });

                  return ListView.builder(
                    itemCount: gifts.length,
                    itemBuilder: (context, index) {
                      final gift = gifts[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        color: gift.purchased
                            ? Colors.red[100]
                            : gift.pledged
                            ? Colors.green[100]
                            : Colors.grey[200],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: ListTile(
                          title: Text(gift.name),
                          subtitle: Text(
                            'Category: ${gift.category}\nPrice: \$${gift.price.toStringAsFixed(2)}',
                          ),
                          trailing: gift.purchased
                              ? const Text(
                            'Purchased',
                            style: TextStyle(color: Colors.red),
                          )
                              : gift.pledged
                              ? gift.pledgerId == widget.currentUserId
                              ? ElevatedButton(
                            onPressed: () => _markGiftAsPurchased(gift),
                            child: const Text('Mark as Purchased'),
                          )
                              : const Text(
                            'Pledged',
                            style: TextStyle(color: Colors.green),
                          )
                              : ElevatedButton(
                            onPressed: () => _pledgeGift(gift),
                            child: const Text('Pledge Gift'),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
