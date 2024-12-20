// notification settings
import 'package:flutter/material.dart';
import 'package:project/controllers/user_controller.dart';
import 'package:project/models/UserModel.dart';
import 'package:project/controllers/notification_controller.dart';

class NotificationSettings extends StatefulWidget {
  final String currentUserId;

  const NotificationSettings({Key? key, required this.currentUserId}) : super(key: key);

  @override
  _NotificationSettingsState createState() => _NotificationSettingsState();
}

class _NotificationSettingsState extends State<NotificationSettings> with SingleTickerProviderStateMixin {
  final UserController _userController = UserController();
  final NotificationController _notificationController = NotificationController();

  List<Map<String, dynamic>> _friendRequests = [];
  List<Map<String, dynamic>> _notifications = [];

  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;

  @override
  void initState() {
    super.initState();
    _fetchFriendRequests();
    _fetchNotifications();

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

  Future<void> _fetchFriendRequests() async {
    try {
      final requests = await _userController.fetchFriendRequests(widget.currentUserId);
      setState(() {
        _friendRequests = requests;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching friend requests: $e')),
      );
    }
  }

  Future<void> _fetchNotifications() async {
    try {
      _notificationController.fetchNotifications(widget.currentUserId).listen((notifications) async {
        List<Map<String, dynamic>> updatedNotifications = [];

        for (var notification in notifications) {
          // Fetch user details for the notification if necessary
          if (notification['pledgerId'] != null) {
            final user = await _userController.fetchUserById(notification['pledgerId']);
            notification['message'] = '${user.name} pledged a gift for your listing';
          }
          updatedNotifications.add(notification);
        }

        setState(() {
          _notifications = updatedNotifications;
        });
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching notifications: $e')),
      );
    }
  }

  Future<void> _respondToFriendRequest(String requestId, bool accepted) async {
    try {
      await _userController.respondToFriendRequest(requestId, accepted);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(accepted ? 'Friend request accepted' : 'Friend request rejected')),
      );
      _fetchFriendRequests(); // Refresh the friend requests list
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error responding to request: $e')),
      );
    }
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
        title: const Text('Notification Settings'),
        backgroundColor: Colors.pinkAccent,
      ),
      body: FadeTransition(
        opacity: _fadeInAnimation,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.pinkAccent, Colors.pink],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Notifications',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: _friendRequests.length + _notifications.length,
                  itemBuilder: (context, index) {
                    if (index < _friendRequests.length) {
                      final request = _friendRequests[index];
                      return Card(
                        color: Colors.white.withOpacity(0.8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: ListTile(
                          leading: const Icon(Icons.person, color: Colors.pink),
                          title: Text(
                            request['fromName'],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text('Friend request from ${request['from']}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.check, color: Colors.green),
                                onPressed: () => _respondToFriendRequest(request['id'], true),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, color: Colors.red),
                                onPressed: () => _respondToFriendRequest(request['id'], false),
                              ),
                            ],
                          ),
                        ),
                      );
                    } else {
                      final notification = _notifications[index - _friendRequests.length];
                      return Card(
                        color: Colors.white.withOpacity(0.8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: ListTile(
                          leading: const Icon(Icons.notifications, color: Colors.orange),
                          title: Text(
                            notification['message'],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}