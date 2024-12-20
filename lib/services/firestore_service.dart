import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project/controllers/user_controller.dart';
import 'package:project/controllers/event_controller.dart';
import 'package:project/controllers/gift_controller.dart';
import 'package:project/models/UserModel.dart';
import 'package:project/models/EventModel.dart';
import 'package:project/models/GiftModel.dart';
import 'package:project/controllers/notification_controller.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final UserController _userController = UserController();
  final EventController _eventController = EventController();
  final GiftController _giftController = GiftController();
  // final NotificationController _notificationController = NotificationController();

  // User-related operations
  Future<List<UserModel>> fetchAllUsersExcept(String currentUserId) async {
    try {
      return await _userController.fetchAllUsersExcept(currentUserId);
    } catch (e) {
      throw Exception("Error fetching users: $e");
    }
  }

  Future<UserModel> getUserById(String userId) async {
    try {
      return await _userController.getUserById(userId);
    } catch (e) {
      throw Exception("Error fetching user by ID: $e");
    }
  }

  Future<void> saveUserData(String userId, UserModel userModel) async {
    await _userController.saveUserData(userId, userModel.toMap());
  }

  Future<List<UserModel>> fetchFriends(String currentUserId) async {
    return await _userController.fetchFriends(currentUserId);
  }

  Future<void> addFriend(String currentUserId, String friendId) async {
    await _userController.addFriend(currentUserId, friendId);
    // Send notification to the friend about the new connection
    final currentUser = await getUserById(currentUserId);
  }

  // Event-related operations
  Future<void> createEvent(String userId, EventModel event) async {
    try {
      final docRef = await _firestore.collection('events').add({
        ...event.toMap(),
        'userId': userId,
        'gifts': [],
        'visibility': [userId], // Ensure creator has visibility by default
      });
      await docRef.update({'id': docRef.id});
    } catch (e) {
      throw Exception("Error creating event: $e");
    }
  }

  Stream<List<EventModel>> fetchEventsByUserId(String userId) {
    return _eventController.fetchEventsByUserId(userId);
  }

  Stream<List<EventModel>> fetchEventsByFriend(String friendId) {
    return _eventController.fetchEventsByFriend(friendId);
  }

  Future<void> addEventVisibility(String eventId, String friendId) async {
    await _eventController.addEventVisibility(eventId, friendId);
  }

  Future<void> updateEvent(String eventId, EventModel updatedEvent) async {
    try {
      await _eventController.updateEvent(eventId, updatedEvent);
    } catch (e) {
      throw Exception("Error updating event: $e");
    }
  }

  Future<void> deleteEvent(String eventId) async {
    try {
      await _eventController.deleteEvent(eventId);
    } catch (e) {
      throw Exception("Error deleting event: $e");
    }
  }

  // Gift-related operations
  Future<void> addGift(String eventId, String userId, GiftModel gift) async {
    await _giftController.addGift(eventId, userId, gift);
  }

  Future<void> deleteGift(String giftId, String eventId) async {
    await _giftController.deleteGift(giftId, eventId);
  }

  Stream<List<GiftModel>> fetchGifts(String eventId) {
    return _giftController.fetchGifts(eventId);
  }

  Future<void> updateGift(String userId, String eventId, String giftId, Map<String, dynamic> updatedFields) async {
    try {
      await _firestore.collection('gifts').doc(giftId).update(updatedFields);
    } catch (e) {
      throw Exception("Error updating gift: $e");
    }
  }

  Future<void> logPledgedGift(String pledgerId, String friendId, String friendName, GiftModel gift) async {
    try {
      await _firestore.collection('pledged_gifts').add({
        'pledgerId': pledgerId,
        'friendId': friendId,
        'giftId': gift.id,
        'giftName': gift.name,
        'eventId': gift.id,
        'pledgedAt': FieldValue.serverTimestamp(),
      });

    } catch (e) {
      throw Exception("Error logging pledged gift: $e");
    }
  }
}
