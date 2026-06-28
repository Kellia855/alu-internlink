# alu_internlink

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
## Folder Structure

lib/
├── main.dart
├── app.dart
├── firebase_options.dart
├── core/
│   ├── constants/     (app_colors, app_strings, sample_data)
│   ├── theme/         (app_theme)
│   ├── router/        (app_routes)
│   └── widgets/       (internlink_app_bar, main_shell, status_badge)
├── models/            (user_profile, opportunity, company, application)
└── features/
    ├── auth/
    │   ├── screens/login_screen.dart
    │   └── widgets/
    ├── home/
    │   ├── screens/home_screen.dart
    │   └── widgets/
    ├── opportunities/
    │   ├── screens/   (list, detail, company profile, post)
    │   └── widgets/
    ├── applications/
    │   ├── screens/applications_screen.dart
    │   └── widgets/
    └── profile/
        ├── screens/   (profile, notifications)
        └── widgets/
