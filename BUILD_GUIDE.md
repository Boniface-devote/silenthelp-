# SilentHelp Flutter App — Build Guide

## 🚀 Quick Start

### 1. **Install Dependencies**
```bash
flutter pub get
```

### 2. **Generate Localization Code**
The app uses `easy_localization` for multi-language support. No code generation is needed — translations are loaded from JSON files in `assets/translations/`.

### 3. **Build & Run**
```bash
# Debug mode
flutter run

# Release mode
flutter run --release
```

---

## 📦 Project Structure

```
lib/
├── main.dart                    # Entry point with localization setup
├── app.dart                     # MaterialApp configuration
├── core/
│   ├── theme/                   # AppColors, AppTextStyles, AppTheme
│   ├── router/                  # go_router configuration with ShellRoute
│   └── constants/               # App constants and routes
├── features/
│   ├── home/                    # HomeScreen with pulsing SOS button
│   ├── emergency/               # EmergencyScreen with SMS + GPS
│   ├── talk/                    # TalkScreen with speech_to_text + flutter_tts
│   ├── phrases/                 # PhrasesScreen with category tabs + TTS
│   ├── id_card/                 # IdCardScreen with QR code generation
│   ├── learn/                   # LearnScreen with sign language cards
│   └── settings/                # SettingsScreen with SharedPreferences
├── shared/
│   ├── widgets/                 # LanguageBar, FeatureCard, PhraseRow, ContactRow, etc.
│   └── providers/               # Global Riverpod providers (locale, etc.)
└── assets/
    └── translations/            # en.json, sw.json, lg.json
```

---

## 🎯 Key Features Implemented

### ✅ **Fully Functional Features**

1. **Multi-Language Support** (EN/SW/LG)
   - Language switched via LanguageBar on every screen
   - All text uses `context.tr('key')` from easy_localization
   - Instant locale updates across the app

2. **Talk Mode**
   - Real-time speech-to-text using `speech_to_text` package
   - Text-to-speech playback with `flutter_tts`
   - Type-and-speak workflow for replies

3. **Quick Phrases**
   - 4 categories: Emergency, Daily, Medical, Shopping
   - Each phrase translatable to EN/SW/LG
   - TTS playback with color-coded play buttons

4. **Emergency SOS**
   - Sends SMS with GPS location to emergency contact
   - Uses `geolocator` for location (with fallback to Kampala coords in simulator)
   - Uses `url_launcher` to trigger SMS compose dialog
   - Haptic feedback on tap for demo drama

5. **Settings & Profile**
   - Save/load user profile via `SharedPreferences`
   - Personal details: name, condition, phone, blood type, medical note
   - Emergency contact information
   - Profile persists across app sessions

6. **ID Card with QR Code**
   - Displays formatted user profile card
   - Generates QR code using `pretty_qr_code`
   - Share via SMS option

7. **Learn Signs**
   - 5 basic sign language lessons
   - Click to see how-to descriptions
   - Placeholder for video integration

8. **Bottom Navigation**
   - 7 tabs: Home, Emergency, Talk, Phrases, My Card, Learn, Settings
   - Emergency tab uses red color when active
   - Smooth navigation with go_router ShellRoute

### 🔶 **Mockable / Simplified**

- **Learn Signs videos** → Currently shows descriptive dialogs (ready for video integration)
- **Speech-to-text languages** → Configured for en_UG, sw_KE, lg locales; may need device testing
- **GPS fallback** → Uses hardcoded Kampala coordinates if geo-permission fails

---

## 🔧 Configuration

### Dependencies (Already in pubspec.yaml)
- `flutter_screenutil` — Responsive design (375×812 reference size)
- `flutter_riverpod` — State management
- `easy_localization` — Multi-language support
- `go_router` — Navigation with ShellRoute
- `firebase_analytics` — (Optional) Analytics
- `geolocator` — GPS location
- `permission_handler` — Runtime permissions
- `speech_to_text` — Speech recognition
- `flutter_tts` — Text-to-speech
- `pretty_qr_code` — QR code generation
- `shared_preferences` — Persistent profile storage
- `url_launcher` — SMS and phone calls

### Android Permissions
Added to `AndroidManifest.xml`:
- `RECORD_AUDIO` — For speech-to-text
- `SEND_SMS` — For SOS emergency messages
- `ACCESS_FINE_LOCATION` — For GPS coordinates
- `CALL_PHONE` — For emergency contact calling
- `INTERNET` — General connectivity

**Min SDK:** Set to 21 in `build.gradle.kts`

### iOS Permissions
Added to `Info.plist`:
- `NSMicrophoneUsageDescription`
- `NSSpeechRecognitionUsageDescription`
- `NSLocationWhenInUseUsageDescription`

---

## 🎨 Theme & Colors

**Dark theme throughout** with these core colors:

```dart
AppColors.background    = #0A0E1A   (Core dark)
AppColors.teal         = #00D4A8   (Primary accent)
AppColors.red          = #FF3B3B   (Emergency)
AppColors.yellow       = #FFB800   (Phrases)
AppColors.blue         = #378ADD   (ID Card)
AppColors.purple       = #7F77DD   (Learn Signs)
```

All typography uses `flutter_screenutil` for responsive scaling.

---

## 🧪 Testing Tips

### Simulator Testing
1. **GPS**: Uses fallback "Kampala, Uganda — 0.3°N 32.6°E" in simulator
2. **SMS**: Opens SMS compose dialog (user must manually send on real device)
3. **Speech-to-text**: May not work in simulator — test on real device
4. **Permissions**: Grant permissionsin device settings before testing

### Real Device Testing
- Ensure all permissions are granted in Android Settings
- Test Emergency SOS with a test SMS number
- Test Talk mode with actual microphone + speaker
- Verify QR code scans properly

---

## 📝 Default User Profile

If user hasn't saved profile yet:
```
Name: John Okello
Condition: DEAF
Phone: +256 701 234 567
Blood Type: O+
Medical Note: I communicate via text
Emergency Contact: Dr. Sarah Nakato
Emergency Number: +256 700 123 456
```

---

## 🚨 Known Limitations (Hackathon Prototype)

1. **GeoLocation in Simulator**: Always shows Kampala coords; real device needed for accurate GPS
2. **SMS Sending**: Opens compose dialog; actual send depends on device/SIM
3. **Speech Recognition**: Quality varies by device and ambient noise
4. **Video Tutorials**: Learn Signs shows placeholder descriptions, not videos

---

## 🛠️ Common Issues & Solutions

### App won't start?
```bash
flutter clean
flutter pub get
flutter run
```

### Permissions not working?
- Android: Make sure you granted permissions in device settings
- iOS: Run on real device (simulator may have limited permission handling)

### Speech-to-text not working?
- Ensure `RECORD_AUDIO` permission is granted
- Test on real device (simulator support is limited)
- Check system language matches app's speech locale

### QR code not scanning?
- Ensure QR code is displayed clearly
- Try different QR scanner apps if your phone app doesn't recognize it

---

## 🎯 Next Steps for Production

1. **Replace placeholder Learn Signs** with actual video links or assets
2. **Integrate real SMS service** (Firebase, Twilio) for guaranteed delivery
3. **Add analytics** via Firebase Analytics
4. **Profile validation** — Add email, date-of-birth, etc.
5. **Dark mode toggle** (currently dark-only)
6. **Accessibility improvements** — Screen reader support, high contrast options

---

## 📱 Launch Checklist

- [ ] Test all 7 screens on real devices
- [ ] Verify all 3 languages (EN/SW/LG) display correctly
- [ ] Test SOS emergency flow with test phone number
- [ ] Confirm profile saves and persists
- [ ] Test Talk mode with speech-to-text
- [ ] Verify QR code generation and scanning
- [ ] Check animations (pulsing SOS button on Home & Emergency)
- [ ] Ensure haptic feedback works on tap
- [ ] Test all TTS playback (phrases + talk replies)
- [ ] Verify bottom nav is accessible on all screens
- [ ] Test Settings screen save and navigation

---

**Built with ❤️ for the deaf community in Uganda.**
