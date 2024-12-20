import 'package:flutter/material.dart';
import 'package:project/services/firebase_auth_service.dart';
import 'package:project/controllers/user_controller.dart';
import 'package:project/models/UserModel.dart';
import 'package:project/views/notification_settings.dart';
import 'package:project/views/event_list_page.dart';
import 'package:project/views/friends.dart';
import 'package:project/views/pledged_gits.dart';
import 'package:project/views/update_info.dart';
import 'dart:convert';

class ProfilePage extends StatefulWidget {
  final String currentUserId;

  const ProfilePage({Key? key, required this.currentUserId}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with SingleTickerProviderStateMixin {
  final UserController _userController = UserController();
  UserModel? _currentUser;
  List<Map<String, dynamic>> _friendRequests = [];
  List<Map<String, dynamic>> _friends = [];

  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _fetchFriendRequests();
    _fetchFriends();

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

  Future<void> _fetchUserData() async {
    try {
      final user = await _userController.getUserById(widget.currentUserId);
      setState(() {
        _currentUser = user;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching user data: $e')),
      );
    }
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

  Future<void> _respondToFriendRequest(String requestId, bool accepted) async {
    try {
      await _userController.respondToFriendRequest(requestId, accepted);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(accepted ? 'Friend request accepted' : 'Friend request rejected')),
      );
      _fetchFriendRequests();
      _fetchFriends();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error responding to request: $e')),
      );
    }
  }

  Future<void> _fetchFriends() async {
    final friends = await _userController.fetchFriends(widget.currentUserId);
    setState(() {
      _friends = friends.map((friend) => friend.toMap()).toList();
    });
  }

  void _logOut(BuildContext context) async {
    try {
      await FirebaseAuthService().signOut();
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error logging out: $e'),
          backgroundColor: Colors.red,
        ),
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
        key: const Key('appBar'),
        title: const Text('My Profile'),
        backgroundColor: Colors.pinkAccent,
      ),
      body: FadeTransition(
        opacity: _fadeInAnimation,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.pinkAccent, Colors.orangeAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                key: const Key('profilePicture'),
                radius: 50,
                backgroundImage: _currentUser?.profilePicture != null
                    ? MemoryImage(base64Decode(_currentUser!.profilePicture!))
                    : const AssetImage('assets/images/profile_icon.png') as ImageProvider,
              ),
              const SizedBox(height: 16.0),
              if (_currentUser != null)
                Center(
                  key: const Key('usernameText'),
                  child: Text(
                    'Username: ${_currentUser!.name}', // Display username instead of user ID
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              const SizedBox(height: 16.0),
              Card(
                key: const Key('profileCard'),
                color: Colors.white.withOpacity(0.8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Column(
                  children: [
                    ListTile(
                      key: const Key('updateInfoTile'),
                      leading: const Icon(Icons.edit, color: Colors.purple),
                      title: const Text('Update User Information'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () async {
                        final updatedUser = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UpdateInfoPage(user: _currentUser!),
                          ),
                        );
                        if (updatedUser != null) {
                          setState(() {
                            _currentUser = updatedUser;
                          });
                        }
                      },
                    ),
                    ListTile(
                      key: const Key('friendsTile'),
                      leading: const Icon(Icons.person, color: Colors.purple),
                      title: const Text('Friends'),
                      subtitle: Text('${_friends.length} friends'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FriendsPage(currentUserId: widget.currentUserId),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      key: const Key('notificationSettingsTile'),
                      leading: const Icon(Icons.notifications, color: Colors.purple),
                      title: const Text('Notification Settings'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NotificationSettings(
                              currentUserId: widget.currentUserId,
                            ),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      key: const Key('myEventsTile'),
                      leading: const Icon(Icons.event, color: Colors.purple),
                      title: const Text('My Created Events'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EventListPage(
                              friendName: "My Events", // Label for the event list
                              currentUserId: widget.currentUserId, // Pass current user ID
                            ),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      key: const Key('myPledgedGiftsTile'),
                      leading: const Icon(Icons.card_giftcard, color: Colors.purple),
                      title: const Text('My Pledged Gifts'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MyPledgedGiftsPage(userId: widget.currentUserId),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Center(
                key: const Key('logoutButton'),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  icon: const Icon(Icons.exit_to_app),
                  label: const Text('Logout'),
                  onPressed: () => _logOut(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
