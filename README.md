# Task Manager App

A Flutter Task Manager application with Firebase Cloud Firestore, SQLite local storage, offline-first sync, Provider state management, search, filtering, sorting, dark mode, and responsive Material UI.

## Features

- Create, edit, delete, and view task details.
- Mark tasks as completed or pending.
- Firestore remote data source.
- SQLite local persistence for offline usage.
- Connectivity-aware sync for pending local changes.
- Local search by title.
- Filter by all, completed, and pending.
- Sort by due date or priority.
- Loading, empty, error, and sync states.
- Responsive UI using `MediaQuery`.
- Feature-based MVVM architecture.

## Requirements

- Flutter SDK compatible with Dart `^3.9.2`
- Android Studio or VS Code
- Firebase project with Cloud Firestore enabled
- Android Firebase config file:
  - `android/app/google-services.json`

## Setup

1. Install dependencies:

```bash
flutter pub get
```

2. Verify Firebase Android config exists:

```text
android/app/google-services.json
```

3. Enable Cloud Firestore in Firebase Console.

For development/testing, Firestore rules can be:

```js
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {
    match /tasks/{taskId} {
      allow read, write: if true;
    }
  }
}
```

Do not use open rules in production. Use Firebase Authentication and restrict access before release.

4. Run the app:

```bash
flutter run
```

## Build APK

Release APK:

```bash
flutter build apk --release
```

Smaller release APKs per CPU architecture:

```bash
flutter build apk --release --split-per-abi
```

Typical Android device APK:

```text
build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
```

## Tests

Run analyzer:

```bash
flutter analyze
```

Run widget tests:

```bash
flutter test
```

## Architecture

The app uses a feature-based MVVM structure. The task feature is split into model, view, viewmodel, repository, and service layers.

```text
lib/
  core/
    theme/
    utils/
    widgets/
  features/
    tasks/
      model/
      view/
      viewmodel/
      repo/
      service/
```

### Layers

- `model`: Task entities, priority/status enums, JSON and local database mapping.
- `view`: Screens and reusable task UI widgets.
- `viewmodel`: UI state, search/filter/sort state, user actions, loading/error/sync indicators.
- `repo`: Coordinates local storage, Firestore, and offline sync.
- `service`: Firestore, SQLite, and connectivity implementations.

### SOLID Notes

- UI widgets do not directly access Firestore or SQLite.
- `TaskViewModel` depends on `TaskRepositoryContract`.
- `TaskRepository` depends on service abstractions:
  - `LocalTaskDataSource`
  - `RemoteTaskDataSource`
  - `NetworkStatusService`
- This keeps data sources replaceable and improves testability.

## Data Flow

1. UI calls a method on `TaskViewModel`.
2. `TaskViewModel` delegates data work to `TaskRepositoryContract`.
3. `TaskRepository` saves changes locally first.
4. If online, it syncs changes to Firestore.
5. If Firestore/network fails, changes remain local and are marked as unsynced.
6. When connectivity is available, pending changes are retried.

## Firestore Collection

The app stores tasks in:

```text
tasks
```

Each task document contains:

- `id`
- `title`
- `description`
- `priority`
- `dueDate`
- `isCompleted`
- `createdDate`
- `updatedDate`
