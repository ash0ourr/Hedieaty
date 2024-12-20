import 'package:flutter/material.dart';
import 'package:project/controllers/event_controller.dart';
import 'package:project/models/EventModel.dart';
import 'friend_gift_list_page.dart';

class FriendEventListPage extends StatefulWidget {
  final String currentUserId;
  final String friendId;
  final String friendName;

  const FriendEventListPage({
    Key? key,
    required this.currentUserId,
    required this.friendId,
    required this.friendName,
  }) : super(key: key);

  @override
  State<FriendEventListPage> createState() => _FriendEventListPageState();
}

class _FriendEventListPageState extends State<FriendEventListPage> with SingleTickerProviderStateMixin {
  final EventController _eventController = EventController();
  String _sortBy = 'name';

  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.friendName}'s Events"),
        backgroundColor: Colors.pinkAccent,
      ),
      body: FadeTransition(
        opacity: _fadeInAnimation,
        child: Column(
          children: [
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
            Expanded(
              child: StreamBuilder<List<EventModel>>(
                stream: _eventController.fetchEventsByFriend(widget.friendId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No events found.'));
                  }

                  // Sort events based on _sortBy selection
                  final events = snapshot.data!;
                  events.sort((a, b) {
                    if (_sortBy == 'name') {
                      return a.name.compareTo(b.name);
                    } else if (_sortBy == 'date') {
                      return a.date.compareTo(b.date);
                    }
                    return 0;
                  });

                  return ListView.builder(
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      final event = events[index];
                      return Card(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ListTile(
                          title: Text(event.name),
                          subtitle: Text(
                            "Date: ${event.date.toLocal().toString().split(' ')[0]} • ${event.description}",
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FriendGiftListPage(
                                  currentUserId: widget.currentUserId,
                                  eventId: event.id,
                                  friendId: widget.friendId,
                                  friendName: widget.friendName,
                                  eventName: event.name,
                                ),
                              ),
                            );
                          },
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

