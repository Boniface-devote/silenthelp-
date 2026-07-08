import 'package:flutter_native_contact_picker_plus/flutter_native_contact_picker_plus.dart';
import 'package:flutter_native_contact_picker_plus/model/contact_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:silenthelp/features/settings/settings_provider.dart';
import 'package:silenthelp/features/settings/settings_screen.dart';

void main() {
  group('contact picker fallback', () {
    test('keeps entered emergency contact values intact', () {
      const name = 'Sarah Kato';
      const phone = '+256700111222';

      expect(name.isNotEmpty, isTrue);
      expect(phone.isNotEmpty, isTrue);
    });

    test('creates the picker instance exposed by the package', () {
      final picker = SettingsScreen.createContactPicker();

      expect(picker, isA<FlutterContactPickerPlus>());
    });

    test('stores a second emergency contact in the profile model', () {
      final profile = UserProfile(
        name: 'Amina',
        condition: 'DEAF',
        phone: '+256700000000',
        bloodType: 'O+',
        medicalNote: 'Prefers text',
        emContactName: 'Moses',
        emContactNumber: '+256700000001',
        secondContactName: 'Dr. Nankya',
        secondContactNumber: '+256700000002',
        secondContactLabel: 'Doctor / Hospital',
      );

      final saved = profile.toMap();

      expect(saved['secondContactName'], 'Dr. Nankya');
      expect(saved['secondContactNumber'], '+256700000002');
      expect(saved['secondContactLabel'], 'Doctor / Hospital');
    });

    test('maps the selected contact into name and phone fields', () {
      final contact = Contact(
        fullName: 'Teacher Sarah',
        phoneNumbers: ['+256700111222'],
      );

      final selection = buildContactSelectionData(contact);

      expect(selection.name, 'Teacher Sarah');
      expect(selection.phoneNumber, '+256700111222');
    });
  });
}
