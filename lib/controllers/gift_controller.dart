import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project/models/GiftModel.dart';
import 'package:project/controllers/notification_controller.dart';
import 'package:project/models/NotificationModel.dart';
import 'package:project/models/UserModel.dart';

class GiftController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NotificationController _notificationController = NotificationController();

  // Add a gift and update the event's gifts array
  Future<void> addGift(String eventId, String userId, GiftModel gift) async {
    try {
      final docRef = await _firestore.collection('gifts').add({
        ...gift.toMap(),
        'eventId': eventId,
        'userId': userId,
      });

      // Add the gift ID to the event's gifts array
      await _firestore.collection('events').doc(eventId).update({
        'gifts': FieldValue.arrayUnion([docRef.id]),
      });

      await docRef.update({'id': docRef.id}); // Update gift document with its ID
    } catch (e) {
      throw Exception("Error adding gift: $e");
    }
  }

  // Delete a gift and remove it from the event's gifts array
  Future<void> deleteGift(String giftId, String eventId) async {
    try {
      await _firestore.collection('gifts').doc(giftId).delete();

      // Remove the gift ID from the event's gifts array
      await _firestore.collection('events').doc(eventId).update({
        'gifts': FieldValue.arrayRemove([giftId]),
      });
    } catch (e) {
      throw Exception("Error deleting gift: $e");
    }
  }

  // Fetch gifts by event ID
  Stream<List<GiftModel>> fetchGifts(String eventId) {
    return _firestore
        .collection('gifts')
        .where('eventId', isEqualTo: eventId)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => GiftModel.fromMap(doc.id, doc.data())).toList());
  }
  // gift_controller.dart

  Future<bool> hasUserPledgedGift(String userId, String giftId) async {
    try {
      final querySnapshot = await _firestore
          .collection('pledged_gifts')
          .where('pledgerId', isEqualTo: userId)
          .where('giftId', isEqualTo: giftId)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      throw Exception("Error checking pledge status: $e");
    }
  }


// Update a gift
  Future<void> updateGift(String userId, String eventId, String giftId, Map<String, dynamic> updatedFields) async {
    try {
      await _firestore.collection('gifts').doc(giftId).update(updatedFields);
    } catch (e) {
      throw Exception("Error updating gift: $e");
    }
  }

  Future<void> removePledgedGift(String userId, String giftId) async {
    try {
      final querySnapshot = await _firestore
          .collection('pledged_gifts')
          .where('pledgerId', isEqualTo: userId)
          .where('giftId', isEqualTo: giftId)
          .get();

      for (var doc in querySnapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      throw Exception("Error removing pledged gift: $e");
    }
  }


  Future<void> logPledgedGift(
      String pledgerId, String friendId, String friendName, GiftModel gift) async {
    try {
      // Fetch the pledger's details
      final pledgerDoc = await _firestore.collection('users').doc(pledgerId).get();
      final pledgerData = pledgerDoc.data();
      if (pledgerData == null) {
        throw Exception("Pledger not found");
      }
      final pledgerName = pledgerData['name'] ?? 'Unknown';

      // Log the pledge in Firestore
      await _firestore.collection('pledged_gifts').add({
        'pledgerId': pledgerId,
        'friendId': friendId,
        'giftId': gift.id,
        'giftName': gift.name,
        'eventId': gift.eventId,
        'pledgedAt': FieldValue.serverTimestamp(),
      });

      // Create the notification message
      final message = "$pledgerName has pledged the gift \"${gift.name}\" for you.";

      // Log the notification for the friend
      final notification = NotificationModel(
        id: '',
        userId: friendId,
        message: message,
        timestamp: DateTime.now(),
      );
      await _firestore.collection('notifications').add(notification.toMap());

      // Send a notification to the friend
      await _notificationController.addNotification(
        friendId,
        message,
      );
    } catch (e) {
      throw Exception("Error logging pledged gift: $e");
    }
  }




  Future<String> fetchUserName(String userId) async {
    final userDoc = await _firestore.collection('users').doc(userId).get();
    return userDoc.data()?['username'] ?? 'Unknown User';
  }



  // Fetch pledged gifts for the current user
  Stream<List<Map<String, dynamic>>> fetchPledgedGifts(String userId) {
    return _firestore
        .collection('pledged_gifts')
        .where('pledgerId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList());
  }
}
