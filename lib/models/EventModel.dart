class EventModel {
  final String id;
  final String name;
  final String description;
  final DateTime date;
  final String location; // Add location field
  final List<String> gifts;
  final List<String> visibility; // List of user IDs who can view the event

  EventModel({
    required this.id,
    required this.name,
    required this.description,
    required this.date,
    required this.location, // Initialize location
    this.gifts = const [],
    this.visibility = const [],
  });

  factory EventModel.fromMap(String id, Map<String, dynamic> map) {
    return EventModel(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      date: map['date'] != null
          ? DateTime.parse(map['date'])
          : DateTime.now(),
      location: map['location'] ?? '', // Parse location from map
      gifts: List<String>.from(map['gifts'] ?? []),
      visibility: List<String>.from(map['visibility'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'date': date.toIso8601String(),
      'location': location, // Add location to map
      'gifts': gifts,
      'visibility': visibility,
    };
  }
}
