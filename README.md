flutterfire configure# 🛡️ Immune Diet AI — Flutter App

A beautiful, AI-powered immunity nutrition app built with **Flutter + Firebase**.

---

## 📁 Project Structure

```
immune_diet_ai/
├── lib/
│   ├── main.dart                    ← App entry point
│   ├── firebase_options.dart        ← Firebase config (auto-generated)
│   ├── models/
│   │   ├── user_model.dart          ← User data model
│   │   ├── meal_model.dart          ← Meal & ingredient models
│   │   └── chat_message.dart        ← Chat message model
│   ├── services/
│   │   ├── auth_service.dart        ← Firebase Auth (register/login/logout)
│   │   ├── firestore_service.dart   ← Firestore (meals, chat history)
│   │   └── app_provider.dart        ← State management (Provider)
│   ├── screens/
│   │   ├── splash_screen.dart       ← Animated splash + session restore
│   │   ├── auth_screen.dart         ← Login & Register
│   │   ├── onboarding_screen.dart   ← 3-step onboarding
│   │   ├── main_screen.dart         ← Bottom navigation shell
│   │   ├── home_screen.dart         ← Dashboard + immunity score
│   │   ├── meal_plan_screen.dart    ← 7-day meal plan (from Firestore)
│   │   ├── chat_screen.dart         ← AI coach chat (saved to Firestore)
│   │   └── profile_screen.dart     ← Profile + settings + sign out
│   ├── widgets/
│   │   └── common_widgets.dart      ← Reusable UI components
│   └── utils/
│       └── app_theme.dart           ← Colors, fonts, theme
├── android/
│   ├── app/
│   │   ├── build.gradle             ← Firebase plugin added
│   │   ├── google-services.json     ← ⚠️ REPLACE with real file
│   │   └── src/main/
│   │       └── AndroidManifest.xml  ← Internet permission added
│   └── build.gradle                 ← Google services classpath
└── pubspec.yaml                     ← All dependencies
```

---

## 🔥 Firebase Collections

```
Firestore Database
└── users/
    └── {uid}/                       ← User document
        ├── name, email, goal, diet
        ├── age, height, weight
        ├── immunityScore, streak
        ├── mealPlans/
        │   ├── Mon/  {meals: [...]}
        │   ├── Tue/  {meals: [...]}
        │   └── ... (7 days)
        └── chatHistory/
            ├── {msgId}  {role, text, timestamp}
            └── ...
```

---

## ⚡ Setup Guide (Step by Step)

### Step 1 — Install Flutter
```bash
# Download Flutter SDK from flutter.dev
# Add to PATH, then verify:
flutter doctor
```

### Step 2 — Install Firebase CLI
```bash
npm install -g firebase-tools
firebase login
```

### Step 3 — Install FlutterFire CLI
```bash
dart pub global activate flutterfire_cli
```

### Step 4 — Open project in Android Studio
```bash
cd immune_diet_ai
flutter pub get
```

### Step 5 — Connect Firebase (THE IMPORTANT STEP)
```bash
flutterfire configure
```
- Select project: **immune-diet-ai**
- Select platforms: **Android** ✅
- This auto-generates `lib/firebase_options.dart`
- This auto-places `android/app/google-services.json`

### Step 6 — Enable Firebase services
In Firebase Console:
1. **Authentication** → Sign-in method → **Email/Password** → Enable
2. **Firestore** → Create database → **Test mode** → `asia-south1`

### Step 7 — Run the app
```bash
# Connect Android device or start emulator, then:
flutter run
```

### Step 8 — Build APK
```bash
flutter build apk --release
# APK location: build/app/outputs/flutter-apk/app-release.apk
```

---

## 📦 Dependencies

| Package | Purpose |
|---------|---------|
| `firebase_core` | Firebase initialization |
| `firebase_auth` | User authentication |
| `cloud_firestore` | Database (profiles, meals, chat) |
| `provider` | State management |
| `google_fonts` | DM Serif Display + Nunito fonts |
| `fl_chart` | Charts (immunity score graphs) |
| `shared_preferences` | Local storage |
| `intl` | Date formatting |

---

## 🎨 Design System

- **Primary font:** DM Serif Display (headings)
- **Body font:** Nunito (text)
- **Colors:** Soft pastel — Mint 🟢 · Lavender 🟣 · Peach 🍑
- **Theme:** Soft & Calm, light mode

---

## 🚀 Features

- ✅ Firebase Auth (register / login / auto session restore)
- ✅ Firestore user profiles
- ✅ 7-day AI meal plans saved to Firestore
- ✅ Real-time AI chat history (Firestore stream)
- ✅ Immunity score tracking
- ✅ Streak counter
- ✅ 3-step onboarding
- ✅ BMI calculation
- ✅ Nutrient progress bars
- ✅ Sign out

---

## 🛠️ Troubleshooting

**"google-services.json not found"**
→ Run `flutterfire configure` or manually download from Firebase Console

**"Firebase app not initialized"**
→ Make sure `await Firebase.initializeApp()` is called in `main.dart`

**"Permission denied" in Firestore**
→ Set Firestore rules to test mode in Firebase Console

**Build fails**
→ Run `flutter clean && flutter pub get`, then rebuild

---

*Built with ❤️ using Flutter + Firebase*
