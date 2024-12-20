import 'package:flutter/material.dart';
import 'package:project/controllers/gift_controller.dart';
import 'package:project/models/GiftModel.dart';
import 'package:project/views/gift_details_page.dart';

class GiftListPage extends StatefulWidget {
  final String userId;
  final String eventId;
  final String eventName;
  final bool isFriend;

  const GiftListPage({
    Key? key,
    required this.userId,
    required this.eventId,
    required this.eventName,
    this.isFriend = false,
  }) : super(key: key);

  @override
  State<GiftListPage> createState() => _GiftListPageState();
}

class _GiftListPageState extends State<GiftListPage> with SingleTickerProviderStateMixin {
  final GiftController _giftController = GiftController();
  String _sortBy = 'name';

  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;

  @override
  void initState() {
    super.initState();
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
        key: Key('app_bar_${widget.eventId}'),
        title: Text('Gifts for ${widget.eventName}'),
        backgroundColor: Colors.pinkAccent,
        leading: IconButton(
          key: const Key('back_button'), // Set the Key for the back button
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          Padding(
            key: const Key('sort_dropdown_container'),
            padding: const EdgeInsets.all(8.0),
            child: DropdownButtonFormField<String>(
              key: const Key('sort_dropdown'),
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
            key: const Key('gift_list_expanded'),
            child: StreamBuilder<List<GiftModel>>(
              stream: _giftController.fetchGifts(widget.eventId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No gifts found.'));
                }

                // Sort gifts based on _sortBy selection
                final gifts = snapshot.data!;
                gifts.sort((a, b) {
                  if (_sortBy == 'name') {
                    return a.name.compareTo(b.name);
                  } else if (_sortBy == 'date') {
                    return a.id.compareTo(b.id); // Assuming id represents date order
                  }
                  return 0;
                });

                return ListView.builder(
                  key: const Key('gift_list_view'),
                  itemCount: gifts.length,
                  itemBuilder: (context, index) {
                    final gift = gifts[index];
                    return Card(
                      key: Key('gift_card_${gift.id}'),
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
                        key: Key('gift_tile_${gift.id}'),
                        title: Text(gift.name),
                        subtitle: Text('${gift.category} - \$${gift.price.toStringAsFixed(2)}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!gift.pledged && !widget.isFriend)
                              IconButton(
                                key: Key('delete_button_${gift.id}'),
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () async {
                                  await _giftController.deleteGift(gift.id, widget.eventId);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('${gift.name} deleted!')),
                                  );
                                },
                              ),
                            if (!gift.pledged && !widget.isFriend)
                              IconButton(
                                key: Key('edit_button_${gift.id}'),
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => GiftDetailsPage(
                                        key: Key('gift_details_${gift.id}'),
                                        userId: widget.userId,
                                        eventId: widget.eventId,
                                        gift: gift,
                                      ),
                                    ),
                                  );
                                },
                              ),
                          ],
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
      floatingActionButton: widget.isFriend
          ? null
          : FloatingActionButton(
        key: const Key('add_gift_button'),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GiftDetailsPage(
                key: const Key('gift_details_add'),
                userId: widget.userId,
                eventId: widget.eventId,
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.pinkAccent,
      ),
    );
  }
}
