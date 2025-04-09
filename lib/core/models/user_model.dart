class UserModel {
  final String uid;
  final String? email;
  final String? displayName;
  final String? photoURL;
  final List<String>? emergencyContacts;
  final Map<String, dynamic>? settings;

  UserModel({
    required this.uid,
    this.email,
    this.displayName,
    this.photoURL,
    this.emergencyContacts,
    this.settings,
  });

  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      uid: data['uid'] as String,
      email: data['email'] as String?,
      displayName: data['displayName'] as String?,
      photoURL: data['photoURL'] as String?,
      emergencyContacts: (data['emergencyContacts'] as List<dynamic>?)?.cast<String>(),
      settings: data['settings'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'emergencyContacts': emergencyContacts,
      'settings': settings,
    };
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoURL,
    List<String>? emergencyContacts,
    Map<String, dynamic>? settings,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      emergencyContacts: emergencyContacts ?? this.emergencyContacts,
      settings: settings ?? this.settings,
    );
  }
} 