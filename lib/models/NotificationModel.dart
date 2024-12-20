import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String userId;
  final String message;
  final DateTime timestamp;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.message,
    required this.timestamp,
  });

  // Factory method to create a NotificationModel from Firestore document
  factory NotificationModel.fromMap(String id, Map<String, dynamic> data) {
    return NotificationModel(
      id: id,
      userId: data['userId'] ?? '',
      message: data['message'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Convert NotificationModel to a Map for saving to Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'message': message,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}
