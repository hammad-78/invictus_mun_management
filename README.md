# MUN Management System

A Flutter Windows Desktop application for managing an MUN event with Firebase
Authentication, Cloud Firestore, Provider state management, MVVM structure, and
PDF report export/printing.

## Firebase setup

1. Create a Firebase project.
2. Enable Email/Password authentication.
3. Create pre-approved admin users in Firebase Authentication.
4. Create an `admins` collection in Firestore. Each admin document ID must be
   the Firebase Auth `uid` and include:

   ```json
   {
     "email": "admin@example.com",
     "role": "admin"
   }
   ```

5. Replace the placeholder values in `lib/firebase_options.dart` with your real
   Firebase options, or run FlutterFire CLI:

   ```bash
   flutterfire configure
   ```

6. Deploy the Firestore rules from `firestore.rules`.

## Run

```bash
flutter pub get
flutter run -d windows
```

## Firestore collections

- `admins/{uid}`
- `delegates/{delegateId}`
- `team_members/{memberId}`
- `attendance/{attendanceId}`
