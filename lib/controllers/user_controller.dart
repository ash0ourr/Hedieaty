import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project/models/UserModel.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:project/controllers/notification_controller.dart';

class UserController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch user by ID
  Future<UserModel> getUserById(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();

      if (!userDoc.exists) {
        throw Exception('User not found');
      }

      return UserModel.fromMap(userDoc.id, userDoc.data()!); // Include the document ID
    } catch (e) {
      throw Exception("Error fetching user by ID: $e");
    }
  }


  Future<void> saveUserData(String userId, Map<String, dynamic> updatedData) async {
    try {
      final userRef = _firestore.collection('users').doc(userId);

      // Check if the document exists
      final docSnapshot = await userRef.get();
      if (docSnapshot.exists) {
        // Update only the provided fields in Firestore
        await userRef.update(updatedData);
      } else {
        // If document does not exist, create it
        await userRef.set(updatedData);
      }
    } catch (e) {
      throw Exception("Error saving user data: $e");
    }
  }

  // Add friend to both users' friends lists
  Future<void> addFriend(String currentUserId, String friendId) async {
    try {
      final currentUserRef = _firestore.collection('users').doc(currentUserId);
      final friendRef = _firestore.collection('users').doc(friendId);

      // Update both users' friend lists
      await currentUserRef.update({
        'friends': FieldValue.arrayUnion([friendId]),
      });
      await friendRef.update({
        'friends': FieldValue.arrayUnion([currentUserId]),
      });
    } catch (e) {
      throw Exception("Error adding friend: $e");
    }
  }

  // Fetch friends of a user
  Future<List<UserModel>> fetchFriends(String currentUserId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(currentUserId).get();
      final friendIds = List<String>.from(userDoc.data()?['friends'] ?? []);

      if (friendIds.isEmpty) return [];

      final querySnapshot = await _firestore
          .collection('users')
          .where(FieldPath.documentId, whereIn: friendIds)
          .get();

      return querySnapshot.docs.map((doc) {
        return UserModel.fromMap(doc.id, doc.data()); // Include Firestore document ID
      }).toList();
    } catch (e) {
      throw Exception("Error fetching friends: $e");
    }
  }

  // Fetch all registered users except the current user
  Future<List<UserModel>> fetchAllUsersExcept(String currentUserId) async {
    try {
      final querySnapshot = await _firestore.collection('users').get();
      return querySnapshot.docs
          .where((doc) => doc.id != currentUserId)
          .map((doc) => UserModel.fromMap(doc.id, doc.data())) // Include Firestore document ID
          .toList();
    } catch (e) {
      throw Exception("Error fetching users: $e");
    }
  }

  Future<void> respondToFriendRequest(String requestId, bool accepted) async {
    try {
      final requestRef = _firestore.collection('friend_requests').doc(requestId);
      final snapshot = await requestRef.get();

      if (!snapshot.exists) {
        throw Exception('Friend request not found.');
      }

      final data = snapshot.data()!;
      final fromUserId = data['from'];
      final toUserId = data['to'];

      if (accepted) {
        // Add each other as friends
        await _firestore.collection('users').doc(fromUserId).update({
          'friends': FieldValue.arrayUnion([toUserId]),
        });
        await _firestore.collection('users').doc(toUserId).update({
          'friends': FieldValue.arrayUnion([fromUserId]),
        });
      }

      // Remove the friend request after response
      await requestRef.delete();
    } catch (e) {
      throw Exception("Error responding to friend request: $e");
    }
  }

  Future<List<Map<String, dynamic>>> fetchFriendRequests(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('friend_requests')
          .where('to', isEqualTo: userId)
          .where('status', isEqualTo: 'pending')
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'from': data['from'],
          'fromName': data['fromName'],
        };
      }).toList();
    } catch (e) {
      throw Exception("Error fetching friend requests: $e");
    }
  }

  Future<UserModel> fetchUserById(String userId) async {
  try {
  final doc = await _firestore.collection('users').doc(userId).get();
  if (doc.exists) {
  return UserModel.fromMap(doc.id, doc.data()!);
  } else {
  throw Exception('User not found');
  }
  } catch (e) {
  throw Exception('Error fetching user: $e');
  }
  }

  Future<void> sendFriendRequest(String fromUserId, String toUserEmail) async {
    try {
      // Fetch the sender's name dynamically
      final fromUser = await getUserById(fromUserId);

      // Retrieve the target user's ID using their email
      final targetUserDoc = await _firestore
          .collection('users')
          .where('email', isEqualTo: toUserEmail)
          .limit(1)
          .get();

      if (targetUserDoc.docs.isEmpty) {
        throw Exception('User with email $toUserEmail not found.');
      }

      final toUserId = targetUserDoc.docs.first.id;

      // Check if a request already exists
      final existingRequest = await _firestore
          .collection('friend_requests')
          .where('from', isEqualTo: fromUserId)
          .where('to', isEqualTo: toUserId)
          .limit(1)
          .get();

      if (existingRequest.docs.isNotEmpty) {
        throw Exception('Friend request already sent.');
      }

      // Create a new friend request with the correct sender name
      await _firestore.collection('friend_requests').add({
        'from': fromUserId,
        'to': toUserId,
        'fromName': fromUser.name, // Fetch sender's name dynamically
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception("Error sending friend request: $e");
    }
  }

}
