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
  final String secondContactName;
  final String secondContactNumber;
  final String secondContactLabel;
  final String medicalContactName;
  final String medicalContactNumber;
  final String medicalContactLabel;

  UserProfile({
    required this.name,
    required this.condition,
    required this.phone,
    required this.bloodType,
    required this.medicalNote,
    required this.emContactName,
    required this.emContactNumber,
    this.secondContactName = '',
    this.secondContactNumber = '',
    this.secondContactLabel = 'Family / Teacher',
    this.medicalContactName = '',
    this.medicalContactNumber = '',
    this.medicalContactLabel = 'Doctor / Nurse / Hospital',
  });

  // Default profile
  static UserProfile defaultProfile() {
    return UserProfile(
      name: 'Your Name',
      condition: 'DEAF',
      phone: '+2567XXXXXXXX',
      bloodType: '??',
      medicalNote: 'I communicate via text',
      emContactName: 'emergency contact name',
      emContactNumber: '+2567XXXXXXXX',
      secondContactName: '',
      secondContactNumber: '',
      secondContactLabel: 'Family / Teacher',
      medicalContactName: '',
      medicalContactNumber: '',
      medicalContactLabel: 'Doctor / Nurse / Hospital',
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
      'secondContactName': secondContactName,
      'secondContactNumber': secondContactNumber,
      'secondContactLabel': secondContactLabel,
      'medicalContactName': medicalContactName,
      'medicalContactNumber': medicalContactNumber,
      'medicalContactLabel': medicalContactLabel,
    };
  }

  // Create from Map
  static UserProfile fromMap(Map<String, dynamic> map) {
    return UserProfile(
      name: map['name'] as String? ?? 'Your Name',
      condition: map['condition'] as String? ?? 'DEAF',
      phone: map['phone'] as String? ?? '+2567XXXXXXXX',
      bloodType: map['bloodType'] as String? ?? '??',
      medicalNote: map['medicalNote'] as String? ?? 'I communicate via text',
      emContactName: map['emContactName'] as String? ?? 'Dr. Sarah Nakato',
      emContactNumber: map['emContactNumber'] as String? ?? '+2567XXXXXXXX',
      secondContactName: map['secondContactName'] as String? ?? '',
      secondContactNumber: map['secondContactNumber'] as String? ?? '',
      secondContactLabel: map['secondContactLabel'] as String? ?? 'Family / Teacher',
      medicalContactName: map['medicalContactName'] as String? ?? '',
      medicalContactNumber: map['medicalContactNumber'] as String? ?? '',
      medicalContactLabel: map['medicalContactLabel'] as String? ?? 'Doctor / Nurse / Hospital',
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
      phone: prefs.getString('phone') ?? '+2567XXXXXXXX',
      bloodType: prefs.getString('bloodType') ?? 'O+',
      medicalNote: prefs.getString('medicalNote') ?? 'I communicate via text',
      emContactName: prefs.getString('emContactName') ?? 'Dr. Sarah Nakato',
      emContactNumber: prefs.getString('emContactNumber') ?? '+2567XXXXXXXX',
      secondContactName: prefs.getString('secondContactName') ?? '',
      secondContactNumber: prefs.getString('secondContactNumber') ?? '',
      secondContactLabel: prefs.getString('secondContactLabel') ?? 'Family / Teacher',
      medicalContactName: prefs.getString('medicalContactName') ?? '',
      medicalContactNumber: prefs.getString('medicalContactNumber') ?? '',
      medicalContactLabel: prefs.getString('medicalContactLabel') ?? 'Doctor / Nurse / Hospital',
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
    await prefs.setString('secondContactName', profile.secondContactName);
    await prefs.setString('secondContactNumber', profile.secondContactNumber);
    await prefs.setString('secondContactLabel', profile.secondContactLabel);
    await prefs.setString('medicalContactName', profile.medicalContactName);
    await prefs.setString('medicalContactNumber', profile.medicalContactNumber);
    await prefs.setString('medicalContactLabel', profile.medicalContactLabel);
    
    state = AsyncValue.data(profile);
  }
}

final settingsProvider = AsyncNotifierProvider<SettingsNotifier, UserProfile>(
  () => SettingsNotifier(),
);

// Profile Completion Model
class ProfileCompletion {
  final bool hasName;
  final bool hasPhone;
  final bool hasBloodType;
  final bool hasEmergencyContactName;
  final bool hasEmergencyContactNumber;
  final bool isEmergencyContactComplete;
  final int completionPercentage;

  ProfileCompletion({
    required this.hasName,
    required this.hasPhone,
    required this.hasBloodType,
    required this.hasEmergencyContactName,
    required this.hasEmergencyContactNumber,
    required this.isEmergencyContactComplete,
    required this.completionPercentage,
  });

  factory ProfileCompletion.fromProfile(UserProfile profile) {
    // Check if default values are still being used
    final hasName = profile.name != 'Your Name' && profile.name.isNotEmpty;
    final hasPhone = profile.phone != '+2567XXXXXXXX' && profile.phone.isNotEmpty;
    final hasBloodType =
        profile.bloodType != 'O+' && profile.bloodType.isNotEmpty;
    final hasEmergencyContactName =
        profile.emContactName != 'Dr. Sarah Nakato' &&
            profile.emContactName.isNotEmpty;
    final hasEmergencyContactNumber =
        profile.emContactNumber != '+2567XXXXXXXX' &&
            profile.emContactNumber.isNotEmpty;

    final isEmergencyContactComplete =
        hasEmergencyContactName && hasEmergencyContactNumber;

    // Calculate completion: 5 fields total
    int completed = 0;
    if (hasName) completed++;
    if (hasPhone) completed++;
    if (hasBloodType) completed++;
    if (hasEmergencyContactName) completed++;
    if (hasEmergencyContactNumber) completed++;

    final completionPercentage = ((completed / 5) * 100).toInt();

    return ProfileCompletion(
      hasName: hasName,
      hasPhone: hasPhone,
      hasBloodType: hasBloodType,
      hasEmergencyContactName: hasEmergencyContactName,
      hasEmergencyContactNumber: hasEmergencyContactNumber,
      isEmergencyContactComplete: isEmergencyContactComplete,
      completionPercentage: completionPercentage,
    );
  }
}

// Provider for profile completion
final profileCompletionProvider =
    FutureProvider<ProfileCompletion>((ref) async {
  final profileAsync = ref.watch(settingsProvider);
  return profileAsync.when(
    data: (profile) => ProfileCompletion.fromProfile(profile),
    loading: () =>
        ProfileCompletion.fromProfile(UserProfile.defaultProfile()),
    error: (_, __) =>
        ProfileCompletion.fromProfile(UserProfile.defaultProfile()),
  );
});

// SOS Log Entry Model
class SOSLogEntry {
  final DateTime timestamp;
  final String message;
  final String status; // 'prepared' or 'opened_in_sms'

  SOSLogEntry({
    required this.timestamp,
    required this.message,
    required this.status,
  });

  // Convert to Map for SharedPreferences
  Map<String, dynamic> toMap() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'message': message,
      'status': status,
    };
  }

  // Create from Map
  static SOSLogEntry fromMap(Map<String, dynamic> map) {
    return SOSLogEntry(
      timestamp: DateTime.parse(map['timestamp'] as String),
      message: map['message'] as String? ?? 'SOS Alert',
      status: map['status'] as String? ?? 'prepared',
    );
  }
}

// SOS Log Notifier
class SOSLogNotifier extends AsyncNotifier<List<SOSLogEntry>> {
  @override
  Future<List<SOSLogEntry>> build() async {
    final prefs = await SharedPreferences.getInstance();
    final logJson = prefs.getStringList('sos_log') ?? [];
    
    return logJson
        .map((entry) => SOSLogEntry.fromMap(
            _parseJsonString(entry) as Map<String, dynamic>))
        .toList();
  }

  Future<void> addLogEntry(SOSLogEntry entry) async {
    final prefs = await SharedPreferences.getInstance();
    final logJson = prefs.getStringList('sos_log') ?? [];
    
    logJson.add(_jsonEncode(entry.toMap()));
    await prefs.setStringList('sos_log', logJson);
    
    // Update state
    final currentList = await build();
    state = AsyncValue.data(currentList);
  }

  Future<void> clearLog() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('sos_log');
    state = const AsyncValue.data([]);
  }

  // Helper to parse JSON string
  dynamic _parseJsonString(String jsonStr) {
    try {
      // Manual JSON parsing for safety
      return _decodeJson(jsonStr);
    } catch (e) {
      return {'timestamp': DateTime.now().toIso8601String(), 'message': 'SOS Alert', 'status': 'prepared'};
    }
  }

  // Simple JSON decoder
  dynamic _decodeJson(String json) {
    json = json.trim();
    if (json.startsWith('{') && json.endsWith('}')) {
      final content = json.substring(1, json.length - 1);
      final pairs = content.split('","');
      final map = <String, dynamic>{};
      
      for (var pair in pairs) {
        final parts = pair.split('":');
        if (parts.length == 2) {
          var key = parts[0].replaceAll('"', '').replaceAll('{', '').trim();
          var value = parts[1].replaceAll('"', '').trim();
          map[key] = value;
        }
      }
      return map;
    }
    return {};
  }

  // Simple JSON encoder
  String _jsonEncode(Map<String, dynamic> map) {
    final entries = map.entries
        .map((e) => '"${e.key}":"${e.value}"')
        .join(',');
    return '{$entries}';
  }
}

final sosLogProvider = AsyncNotifierProvider<SOSLogNotifier, List<SOSLogEntry>>(
  () => SOSLogNotifier(),
);
