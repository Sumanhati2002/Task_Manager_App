import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/app_badge.dart';
import '../../../core/widgets/app_info_section.dart';
import '../model/task.dart';
import '../viewmodel/task_viewmodel.dart';
import 'task_form_screen.dart';
import 'widgets/delete_confirmation_dialog.dart';
import 'widgets/task_style.dart';

class TaskDetailScreen extends StatelessWidget {
  const TaskDetailScreen({super.key, required this.taskId});

  final String taskId;

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskViewModel>(
      builder: (context, viewModel, _) {
        final task = _findTask(viewModel.tasks, taskId);
        if (task == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Task Details')),
            body: const Center(
              child: Text(
                'Task not found.',
                style: TextStyle(color: AppColors.muted, fontSize: 16),
              ),
            ),
          );
        }

        final priorityColor = task.priority.color;
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
            elevation: 0,
            scrolledUnderElevation: 0,
            iconTheme: IconThemeData(
              color: isDark ? Colors.white : AppColors.ink,
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(
                color: isDark ? AppColors.darkBorder : AppColors.border,
                height: 1,
              ),
            ),
            title: Text(
              'Task Details',
              style: TextStyle(
                color: isDark ? Colors.white : AppColors.ink,
                fontWeight: FontWeight.w900,
                fontSize: 20,
              ),
            ),
            actions: [
              IconButton(
                tooltip: 'Edit',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => TaskFormScreen(task: task),
                    ),
                  );
                },
                icon: Icon(
                  Icons.edit_outlined,
                  color: isDark ? Colors.white : AppColors.ink,
                ),
              ),
              IconButton(
                tooltip: 'Delete',
                onPressed: () async {
                  final confirmed = await showDeleteConfirmationDialog(
                    context,
                    task,
                  );
                  if (confirmed == true) {
                    await viewModel.deleteTask(task);
                    if (context.mounted) Navigator.of(context).pop();
                  }
                },
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.danger,
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: SafeArea(
            child: ListView(
              padding: Responsive.pagePadding(context, top: 12),
              children: [
                ResponsiveCenter(
                  maxWidth: 760,
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              priorityColor,
                              isDark ? AppColors.darkBackground : AppColors.ink,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(26),
                          boxShadow: [
                            BoxShadow(
                              color: priorityColor.withValues(alpha: 0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Icon(
                                    task.isCompleted
                                        ? Icons.check_circle_rounded
                                        : Icons.pending_actions_rounded,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ),
                                const Spacer(),
                                AppBadge(
                                  label: task.priority.label,
                                  icon: Icons.flag_rounded,
                                  color: Colors.white,
                                  translucentOnDark: true,
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            Text(
                              task.title,
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    height: 1.2,
                                  ),
                            ),
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                AppBadge(
                                  label: task.statusLabel,
                                  icon: task.statusIcon,
                                  color: Colors.white,
                                  translucentOnDark: true,
                                ),
                                if (task.syncStatus != TaskSyncStatus.synced)
                                  const AppBadge(
                                    label: 'Unsynced',
                                    icon: Icons.sync_problem_rounded,
                                    color: Colors.white,
                                    translucentOnDark: true,
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      AppInfoSection(
                        title: 'Description',
                        value: task.description,
                        icon: Icons.notes_rounded,
                      ),
                      AppInfoSection(
                        title: 'Due date',
                        value: DateFormat(
                          'EEEE, MMMM d, yyyy',
                        ).format(task.dueDate),
                        icon: Icons.event_rounded,
                      ),
                      AppInfoSection(
                        title: 'Created',
                        value: DateFormat(
                          'MMM d, yyyy h:mm a',
                        ).format(task.createdDate),
                        icon: Icons.add_circle_outline_rounded,
                      ),
                      if (task.updatedDate != null)
                        AppInfoSection(
                          title: 'Last updated',
                          value: DateFormat(
                            'MMM d, yyyy h:mm a',
                          ).format(task.updatedDate!),
                          icon: Icons.update_rounded,
                        ),
                      const SizedBox(height: 20),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  (task.isCompleted
                                          ? AppColors.muted
                                          : AppColors.success)
                                      .withValues(alpha: 0.3),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: task.isCompleted
                                ? AppColors.ink
                                : AppColors.success,
                            minimumSize: const Size.fromHeight(56),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          onPressed: () => viewModel.toggleCompletion(task),
                          icon: Icon(
                            task.isCompleted
                                ? Icons.undo_rounded
                                : Icons.check_circle_rounded,
                            size: 22,
                          ),
                          label: Text(
                            task.isCompleted
                                ? 'Mark as pending'
                                : 'Mark as completed',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Task? _findTask(List<Task> tasks, String id) {
    for (final task in tasks) {
      if (task.id == id) return task;
    }
    return null;
  }
}
