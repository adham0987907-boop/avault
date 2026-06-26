# AVAULT - Secure Encrypted Vault

A production-ready Flutter application for secure storage of encrypted files, notes, passwords, and more with military-grade security.

## Features

- 🔐 **Military-Grade Encryption**: AES-256-GCM encryption with PBKDF2 key derivation
- 📱 **Biometric Security**: Fingerprint and Face ID support
- 🔑 **PIN Protection**: Create and manage secure PIN codes
- 📁 **Encrypted Vault**: Support for Images, Videos, Documents, Audio, and ZIP files
- 📝 **Secure Notes**: Create and manage encrypted notes
- 🔐 **Password Manager**: Generate and manage secure passwords with strength meter
- 📸 **Hidden Gallery**: Hidden file gallery with privacy features
- 🎥 **Secure Camera**: Built-in camera for secure photo capture
- ⭐ **Favorites**: Mark important files as favorites
- 🕐 **Recent Files**: Quick access to recently accessed files
- 🔍 **Search**: Fast and efficient file search
- 📂 **Folder Management**: Organize files into custom folders
- 🔒 **Auto Lock**: Automatic session timeout and app locking
- 🛡️ **Screenshot Protection**: Prevent unauthorized screenshots
- 🌙 **Theme Support**: Dark, Light, and AMOLED themes
- 🌍 **Localization**: English and Arabic support
- 💾 **Backup/Restore**: Complete backup and restore functionality
- 📱 **Responsive UI**: Beautiful Material 3 design with smooth animations

## Project Structure

```
lib/
├── app/                 # App configuration and setup
├── core/               # Core utilities, constants, and services
├── data/               # Data layer (repositories, local storage)
├── domain/             # Domain layer (entities, use cases)
├── features/           # Feature modules (UI, state management)
└── shared/             # Shared utilities and widgets
```

## Architecture

- **Clean Architecture**: Separation of concerns with app, data, domain, and features layers
- **Riverpod**: State management with providers and family modifiers
- **GoRouter**: Type-safe navigation
- **Repository Pattern**: Abstract data access layer
- **SOLID Principles**: Maintainable and testable code

## Security

- AES-256-GCM encryption for all files
- PBKDF2 key derivation with salt
- Flutter Secure Storage for credentials
- Biometric authentication
- Session timeout and auto-lock
- Screenshot protection

## Getting Started

### Prerequisites

- Flutter 3.35+
- Dart 3.0+
- iOS 11.0+ / Android 5.0+

### Installation

```bash
# Clone the repository
git clone https://github.com/adham0987907-boop/avault.git
cd avault

# Install dependencies
flutter pub get

# Run the app
flutter run
```

### Build Release

```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release
```

## Development

### Code Generation

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Testing

```bash
flutter test
```

### Analysis

```bash
flutter analyze
```

## Project Statistics

- **Languages**: Dart/Flutter
- **Minimum SDK**: Flutter 3.35+
- **Architecture**: Clean Architecture
- **State Management**: Riverpod
- **Navigation**: GoRouter
- **Database**: Hive + Secure Storage
- **Encryption**: AES-256-GCM + PBKDF2

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Author

Adham - [@adham0987907-boop](https://github.com/adham0987907-boop)
