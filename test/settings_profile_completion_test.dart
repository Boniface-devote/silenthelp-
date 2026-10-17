import 'package:flutter_test/flutter_test.dart';
import 'package:silenthelp/features/settings/settings_provider.dart';

void main() {
  group('ProfileCompletion', () {
    test('default profile does not count placeholders as complete', () {
      final completion = ProfileCompletion.fromProfile(
        UserProfile.defaultProfile(),
      );

      expect(completion.completionPercentage, 0);
      expect(completion.isEmergencyContactComplete, isFalse);
    });

    test('all valid profile details count as complete', () {
      final profile = UserProfile(
        name: 'Amina',
        condition: 'DEAF',
        phone: '+256700000000',
        bloodType: 'O+',
        medicalNote: 'Prefers text',
        emContactName: 'Moses',
        emContactNumber: '+256700000001',
      );

      final completion = ProfileCompletion.fromProfile(profile);

      expect(completion.completionPercentage, 100);
      expect(completion.isEmergencyContactComplete, isTrue);
    });

    test('legacy placeholder values do not count as complete', () {
      final profile = UserProfile(
        name: 'Your Name',
        condition: 'DEAF',
        phone: '+2567XXXXXXXX',
        bloodType: '??',
        medicalNote: 'I communicate via text',
        emContactName: 'emergency contact name',
        emContactNumber: '+2567XXXXXXXX',
      );

      final completion = ProfileCompletion.fromProfile(profile);

      expect(completion.completionPercentage, 0);
      expect(completion.isEmergencyContactComplete, isFalse);
    });
  });
}
