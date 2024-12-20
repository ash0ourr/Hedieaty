class UserModel {
  final String id; // Document ID
  final String email;
  final String name;
  final List<String> friends; // List of friend IDs
  final String? profilePicture; // Add profilePicture field

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.friends = const [],
    this.profilePicture, // Initialize profilePicture
  });

  // Convert UserModel to a Map
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'friends': friends,
      'profilePicture': profilePicture, // Add profilePicture to map
    };
  }

  // Create UserModel from a Map
  factory UserModel.fromMap(String id, Map<String, dynamic> map) {
    return UserModel(
      id: id,
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      friends: List<String>.from(map['friends'] ?? []),
      profilePicture: map['profilePicture'], // Parse profilePicture from map
    );
  }
}
