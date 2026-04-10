# PawOut

PawOut is a Flutter-based dog walking app starter project.
It currently includes the app structure, route setup, basic UI screens, and state-management scaffolding for core features.

## Overview

The project is organized around the main user flows of a dog walking service:

- authentication
- dog profile management
- walk start and walk history
- ranking/community

At this stage, most screens are scaffolded and connected through routes, while backend integration and production logic are still minimal.

## Tech Stack

- Flutter
- Dart
- Provider
- Dio / HTTP
- Shared Preferences
- Geolocator
- Google Maps Flutter
- Pedometer
- Image Picker

## Current Features

- app entry point and theme configuration
- named route management
- home screen with navigation shortcuts
- login and signup screens
- dog profile list/detail/register screen scaffolding
- walk start, active, and history screen scaffolding
- ranking screen scaffolding
- reusable widgets and common constants
- placeholder service layer for API and location features

## Project Structure

```text
lib/
  core/
    constants/
    utils/
    widgets/
  features/
    auth/
    dog_profile/
    home/
    ranking/
    walk/
  services/
  main.dart
```

## Getting Started

### 1. Install dependencies

```bash
flutter pub get
```

### 2. Run the app

```bash
flutter run
```

### 3. Run tests

```bash
flutter test
```

## Main Routes

The app currently defines these primary routes:

- `/`
- `/login`
- `/signup`
- `/dogs`
- `/dogs/detail`
- `/walk/start`
- `/walk/active`
- `/walk/history`
- `/ranking`

## Development Notes

- `ApiService` and `LocationService` are placeholders and need real implementations.
- Some screens in `lib/main.dart` still include temporary placeholder flow.
- Dependencies for maps, pedometer, image handling, and networking are added, but most are not fully wired yet.
- Platform permission setup may still be required for Android and iOS before location or step tracking features work.

## Suggested Next Steps

- connect authentication state with `Provider`
- replace placeholder navigation in `main.dart` with the shared route table
- implement API client and persistence layer
- add real dog profile CRUD flow
- wire location, pedometer, and walk tracking logic
- add widget and integration tests

## Status

This repository is currently a foundation build rather than a production-ready app.
