import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project/models/EventModel.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:project/controllers/notification_controller.dart';

class EventController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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


  Future<void> addEventVisibility(String eventId, String friendId) async {
    try {
      await _firestore.collection('events').doc(eventId).update({
        'visibility': FieldValue.arrayUnion([friendId]),
      });
    } catch (e) {
      throw Exception("Error updating event visibility: $e");
    }
  }


  Stream<List<EventModel>> fetchEventsByUserId(String userId) {
    return _firestore
        .collection('events')
        .where('userId', isEqualTo: userId) // Query by userId field
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => EventModel.fromMap(doc.id, doc.data()))
        .toList());
  }

  Stream<List<EventModel>> fetchEventsByFriend(String friendId) {
    return _firestore
        .collection('events')
        .where('userId', isEqualTo: friendId) // Fetch all events by friend
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
      return EventModel.fromMap(doc.id, doc.data());
    }).toList());
  }

  Future<void> updateEvent(String eventId, EventModel updatedEvent) async {
    try {
      await _firestore.collection('events').doc(eventId).update(updatedEvent.toMap());
    } catch (e) {
      throw Exception("Error updating event: $e");
    }
  }

  Future<void> deleteEvent(String eventId) async {
    try {
      await _firestore.collection('events').doc(eventId).delete();
    } catch (e) {
      throw Exception("Error deleting event: $e");
    }
  }
}
