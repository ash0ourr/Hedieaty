import 'package:cloud_firestore/cloud_firestore.dart';
// Updated GiftModel
class GiftModel {
  final String id;
  final String name;
  final String category;
  final double price;
  final String description;
  final String status;
  final bool pledged;
  final bool purchased;
  final String eventId;
  final String? pledgerId; // Add pledgerId field
  final DateTime date;
  final DateTime? createdAt;
  final String? image;

  GiftModel({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.description,
    required this.status,
    required this.pledged,
    this.purchased = false,
    required this.eventId,
    this.pledgerId, // Initialize pledgerId
    required this.date,
    this.createdAt,
    this.image,
  });

  GiftModel copyWith({
    String? id,
    String? name,
    String? category,
    double? price,
    String? description,
    String? status,
    bool? pledged,
    bool? purchased,
    String? eventId,
    String? pledgerId, // Add pledgerId to copyWith
    DateTime? date,
    DateTime? createdAt,
    String? image,
  }) {
    return GiftModel(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      price: price ?? this.price,
      description: description ?? this.description,
      status: status ?? this.status,
      pledged: pledged ?? this.pledged,
      purchased: purchased ?? this.purchased,
      eventId: eventId ?? this.eventId,
      pledgerId: pledgerId ?? this.pledgerId, // Update pledgerId
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      image: image ?? this.image,
    );
  }

  factory GiftModel.fromMap(String id, Map<String, dynamic> map) {
    return GiftModel(
      id: id,
      name: map['name'] ?? '',
      category: map['category'] ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      description: map['description'] ?? '',
      status: map['status'] ?? 'Available',
      pledged: map['pledged'] ?? false,
      purchased: map['purchased'] ?? false,
      eventId: map['eventId'] ?? '',
      pledgerId: map['pledgerId'], // Parse pledgerId from map
      date: (map['date'] as Timestamp).toDate(),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      image: map['image'], // Parse image from map
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'price': price,
      'description': description,
      'status': status,
      'pledged': pledged,
      'purchased': purchased,
      'eventId': eventId,
      'pledgerId': pledgerId, // Add pledgerId to map
      'date': date,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'image': image, // Add image to map
    };
  }
}
