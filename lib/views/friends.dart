import 'package:flutter/material.dart';
import 'package:project/controllers/user_controller.dart';
import 'package:project/models/UserModel.dart';
import 'friend_event_list_page.dart';
import 'dart:convert';

class FriendsPage extends StatefulWidget {
  final String currentUserId;

  const FriendsPage({Key? key, required this.currentUserId}) : super(key: key);

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> with SingleTickerProviderStateMixin {
  final UserController _userController = UserController();
  List<UserModel> _friends = [];

  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;

  @override
  void initState() {
    super.initState();
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

  Future<void> _fetchFriends() async {
    try {
      final friends = await _userController.fetchFriends(widget.currentUserId);
      setState(() {
        _friends = friends;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching friends: $e')),
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
        title: const Text('My Friends'),
        backgroundColor: Colors.pinkAccent,
      ),
      body: FadeTransition(
        opacity: _fadeInAnimation,
        child: _friends.isEmpty
            ? const Center(child: Text('No friends yet'))
            : ListView.builder(
          itemCount: _friends.length,
          itemBuilder: (context, index) {
            final friend = _friends[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: friend.profilePicture != null
                      ? MemoryImage(base64Decode(friend.profilePicture!))
                      : const AssetImage('assets/images/default_profile.png') as ImageProvider,
                  radius: 25,
                ),
                title: Text(
                  friend.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(friend.email),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FriendEventListPage(
                        currentUserId: widget.currentUserId,
                        friendId: friend.id, // Use friend's ID as unique identifier
                        friendName: friend.name,
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
