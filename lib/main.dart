import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'features/tasks/repo/task_repository.dart';
import 'features/tasks/service/connectivity_service.dart';
import 'features/tasks/service/firestore_task_service.dart';
import 'features/tasks/service/local_task_service.dart';
import 'features/tasks/view/task_list_screen.dart';
import 'features/tasks/viewmodel/task_viewmodel.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (_) {
    // Keep the app local-first until Firebase configuration is added.
  }
  runApp(const TaskManagerApp());
}

class TaskManagerApp extends StatelessWidget {
  const TaskManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TaskViewModel(
        repository: TaskRepository(
          localService: LocalTaskService(),
          remoteService: FirestoreTaskService(),
          connectivityService: ConnectivityService(),
        ),
      ),
      child: Consumer<TaskViewModel>(
        builder: (context, viewModel, _) {
          return MaterialApp(
            title: 'Task Manager',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: viewModel.themeMode,
            builder: (context, child) {
              return Listener(
                behavior: HitTestBehavior.translucent,
                onPointerDown: (_) {
                  FocusManager.instance.primaryFocus?.unfocus();
                },
                child: child ?? const SizedBox.shrink(),
              );
            },
            home: const TaskListScreen(),
          );
        },
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const TaskManagerApp();
  }
}
