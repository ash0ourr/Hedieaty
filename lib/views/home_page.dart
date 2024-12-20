import 'dart:convert'; // To decode base64 profile picture
import 'package:flutter/material.dart';
import 'package:project/controllers/notification_controller.dart';
import 'package:project/controllers/user_controller.dart';
import 'package:project/models/UserModel.dart';
import 'package:project/views/event_list_page.dart';
import 'create_event_page.dart';
import 'notification_screen.dart';

class HomePage extends StatefulWidget {
  final String currentUserId;

  const HomePage({Key? key, required this.currentUserId}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  final UserController _userController = UserController();
  final NotificationController _notificationController = NotificationController();

  List<UserModel> _allUsers = [];
  List<UserModel> _filteredUsers = [];
  List<UserModel> _friends = [];
  List<String> _sentRequests = [];
  String _searchQuery = '';

  UserModel? _currentUser; // Store current user info, including profile picture
  bool _isLoading = true;

  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;

  // Keys for integration testing
  final Key _searchFieldKey = Key('searchField');
  final Key _userListKey = Key('userList');
  final Key _userCardKey = Key('userCard');
  final Key _eventButtonKey = Key('eventButton');
  final Key _profilePictureKey = Key('profilePicture');
  final Key _appBarTitleKey = Key('appBarTitle');

  @override
  void initState() {
    super.initState();
    _initializeData();

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

    // Listen for notifications
    _listenForNotifications();
  }

  Future<void> _initializeData() async {
    try {
      await _fetchCurrentUser();
      await Future.wait([_fetchUsers(), _fetchFriends()]);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error initializing data: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchCurrentUser() async {
    try {
      final currentUser = await _userController.getUserById(widget.currentUserId);
      setState(() {
        _currentUser = currentUser;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching current user: $e')),
      );
    }
  }

  Future<void> _fetchUsers() async {
    final users = await _userController.fetchAllUsersExcept(widget.currentUserId);
    setState(() {
      _allUsers = users;
      _filteredUsers = users;
    });
  }

  Future<void> _fetchFriends() async {
    final friends = await _userController.fetchFriends(widget.currentUserId);
    setState(() {
      _friends = friends;
    });
  }

  void _filterUsers(String query) {
    setState(() {
      _searchQuery = query;
      _filteredUsers = _allUsers
          .where((user) =>
      user.name.toLowerCase().contains(query.toLowerCase()) ||
          user.email.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Future<void> _addFriend(UserModel user) async {
    try {
      await _userController.sendFriendRequest(widget.currentUserId, user.email);
      setState(() {
        _sentRequests.add(user.email);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Friend request sent to ${user.name}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  void _listenForNotifications() {
    _notificationController.fetchNotifications(widget.currentUserId).listen((notifications) {
      if (notifications.isNotEmpty) {
        final notification = notifications.first; // Show the first notification
        _showNotificationOverlay(notification['message']);
        _notificationController.clearNotifications(widget.currentUserId);
      }
    });
  }

  void _showNotificationOverlay(String message) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false, // Makes the overlay non-opaque
        pageBuilder: (_, __, ___) => NotificationScreen(message: message),
      ),
    );
  }

  Widget _buildUserList() {
    return ListView.builder(
      key: _userListKey,
      itemCount: _filteredUsers.length,
      itemBuilder: (context, index) {
        final user = _filteredUsers[index];
        return Card(
          key: _userCardKey,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: ListTile(
            leading: const Icon(Icons.person, color: Colors.pinkAccent),
            title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(user.email),
            trailing: _friends.any((friend) => friend.email == user.email)
                ? const Icon(Icons.favorite, color: Colors.red)
                : _sentRequests.contains(user.email)
                ? const Icon(Icons.hourglass_empty, color: Colors.grey)
                : IconButton(
              icon: const Icon(Icons.person_add, color: Colors.green),
              onPressed: () => _addFriend(user),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : FadeTransition(
      opacity: _fadeInAnimation,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.pinkAccent,
          leading: GestureDetector(
            key: _profilePictureKey,
            onTap: () async {
              await Navigator.pushNamed(context, '/profilePage', arguments: {
                'currentUserId': widget.currentUserId,
              }).then((_) => _fetchCurrentUser());
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                radius: 20,
                backgroundImage: _currentUser?.profilePicture != null
                    ? MemoryImage(base64Decode(_currentUser!.profilePicture!))
                    : const AssetImage('assets/images/profile_icon.png') as ImageProvider,
              ),
            ),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.card_giftcard, color: Colors.white, size: 28),
              SizedBox(width: 8),
              Text(
                'Hedieaty',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w700,
                  fontSize: 22,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              key: _eventButtonKey,
              icon: const Icon(Icons.event, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateEventPage(currentUserId: widget.currentUserId),
                  ),
                );
              },
            ),
          ],
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.pinkAccent, Colors.orangeAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: TextField(
                  key: _searchFieldKey,
                  onChanged: _filterUsers,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search, color: Colors.pinkAccent),
                    hintText: 'Search for users...',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),
              Expanded(child: _buildUserList()),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.event_available),
              label: 'My Events',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
          ],
          onTap: (index) {
            if (index == 0) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EventListPage(
                    currentUserId: widget.currentUserId,
                    friendName: _currentUser?.name ?? 'My',
                  ),
                ),
              );
            }
            if (index == 1) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => HomePage(currentUserId: widget.currentUserId),
                ),
              );
            }
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
