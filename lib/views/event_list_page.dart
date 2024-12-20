import 'package:flutter/material.dart';
import 'package:project/views/gift_list_page.dart';
import 'package:project/views/edit_event_page.dart';
import 'package:project/models/EventModel.dart';
import 'package:project/controllers/event_controller.dart';

class EventListPage extends StatefulWidget {
  final String friendName;
  final String currentUserId;

  const EventListPage({
    Key? key,
    required this.friendName,
    required this.currentUserId,
  }) : super(key: key);

  @override
  State<EventListPage> createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> with SingleTickerProviderStateMixin {
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
        key: const Key('back_button_key'),
        title: Text("${widget.friendName}'s Events"),
        backgroundColor: Colors.pinkAccent,
        leading: IconButton(
          key: const Key('back_button'),
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: FadeTransition(
        opacity: _fadeInAnimation,
        child: Column(
          children: [
            Padding(
              key: const Key('sort_dropdown'),
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
                stream: _eventController.fetchEventsByUserId(widget.currentUserId),
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
                    key: const Key('event_list'),
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      final event = events[index];
                      return Card(
                        key: Key('event_card_${index + 1}'), // Adjusted Key
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ListTile(
                          key: Key('event_list_tile_${index + 1}'),
                          title: Text(event.name),
                          subtitle: Text(
                            "Date: ${event.date.toLocal().toString().split(' ')[0]} • ${event.description}",
                          ),
                          trailing: Row(
                            key: Key('event_trailing_${index + 1}'),
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                key: Key('edit_button_${index + 1}'),
                                icon: const Icon(Icons.edit, color: Colors.amber),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditEventPage(
                                        eventId: event.id,
                                        existingEvent: event.toMap(),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                key: Key('delete_button_${index + 1}'),
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () async {
                                  await _eventController.deleteEvent(event.id);
                                  setState(() {});
                                },
                              ),
                            ],
                          ),
                          onTap: () async {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => GiftListPage(
                                  userId: widget.currentUserId,
                                  eventId: event.id,
                                  eventName: event.name,
                                  isFriend: false,
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
