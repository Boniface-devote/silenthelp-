import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfile {
  final String name;
  final String condition;
  final String phone;
  final String bloodType;
  final String medicalNote;
  final String emContactName;
  final String emContactNumber;

  UserProfile({
    required this.name,
    required this.condition,
    required this.phone,
    required this.bloodType,
    required this.medicalNote,
    required this.emContactName,
    required this.emContactNumber,
  });

  // Default profile
  static UserProfile defaultProfile() {
    return UserProfile(
      name: 'John Okello',
      condition: 'DEAF',
      phone: '+256 701 234 567',
      bloodType: 'O+',
      medicalNote: 'I communicate via text',
      emContactName: 'Dr. Sarah Nakato',
      emContactNumber: '+256 700 123 456',
    );
  }

  // Convert to Map for SharedPreferences
  Map<String, String> toMap() {
    return {
      'name': name,
      'condition': condition,
      'phone': phone,
      'bloodType': bloodType,
      'medicalNote': medicalNote,
      'emContactName': emContactName,
      'emContactNumber': emContactNumber,
    };
  }

  // Create from Map
  static UserProfile fromMap(Map<String, dynamic> map) {
    return UserProfile(
      name: map['name'] as String? ?? 'John Okello',
      condition: map['condition'] as String? ?? 'DEAF',
      phone: map['phone'] as String? ?? '+256 701 234 567',
      bloodType: map['bloodType'] as String? ?? 'O+',
      medicalNote: map['medicalNote'] as String? ?? 'I communicate via text',
      emContactName: map['emContactName'] as String? ?? 'Dr. Sarah Nakato',
      emContactNumber: map['emContactNumber'] as String? ?? '+256 700 123 456',
    );
  }
}

class SettingsNotifier extends AsyncNotifier<UserProfile> {
  @override
  Future<UserProfile> build() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Try to load from SharedPreferences
    final name = prefs.getString('name');
    
    if (name == null) {
      // Return default profile if nothing saved
      return UserProfile.defaultProfile();
    }

    // Load all saved values
    return UserProfile(
      name: name,
      condition: prefs.getString('condition') ?? 'DEAF',
      phone: prefs.getString('phone') ?? '+256 701 234 567',
      bloodType: prefs.getString('bloodType') ?? 'O+',
      medicalNote: prefs.getString('medicalNote') ?? 'I communicate via text',
      emContactName: prefs.getString('emContactName') ?? 'Dr. Sarah Nakato',
      emContactNumber: prefs.getString('emContactNumber') ?? '+256 700 123 456',
    );
  }

  Future<void> saveProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', profile.name);
    await prefs.setString('condition', profile.condition);
    await prefs.setString('phone', profile.phone);
    await prefs.setString('bloodType', profile.bloodType);
    await prefs.setString('medicalNote', profile.medicalNote);
    await prefs.setString('emContactName', profile.emContactName);
    await prefs.setString('emContactNumber', profile.emContactNumber);
    
    state = AsyncValue.data(profile);
  }
}

final settingsProvider = AsyncNotifierProvider<SettingsNotifier, UserProfile>(
  () => SettingsNotifier(),
);
