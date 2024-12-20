import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Listen for notifications in real-time
  void listenForNotifications(Function(String) onNotification) {
    _firestore.collection('notifications').snapshots().listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final data = change.doc.data();
          final message = data?['message'] ?? 'You have a new notification!';
          onNotification(message);
        }
      }
    });
  }

  Future<void> addPledgeNotification({
    required String eventOwnerId,
    required String pledgerName,
    required String giftName,
  }) async {
    // Notify the gift owner that the gift was pledged
    final message = '$pledgerName has pledged the gift "$giftName" to you!';
    await _firestore.collection('notifications').add({
      'userId': eventOwnerId,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<Map<String, dynamic>>> fetchNotifications(String userId) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  // Add a new notification to Firestore
  Future<void> addNotification(String userId, String message) async {
    await _firestore.collection('notifications').add({
      'userId': userId,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }


  // Clear notifications for a specific user
  Future<void> clearNotifications(String userId) async {
    final query = await _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .get();

    for (var doc in query.docs) {
      await doc.reference.delete();
    }
  }
}