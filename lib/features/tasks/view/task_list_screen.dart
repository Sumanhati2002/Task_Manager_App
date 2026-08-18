import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/app_badge.dart';
import '../../../core/widgets/app_panel.dart';
import '../model/task.dart';
import '../model/task_filter.dart';
import '../viewmodel/task_viewmodel.dart';
import 'task_detail_screen.dart';
import 'task_form_screen.dart';
import 'widgets/delete_confirmation_dialog.dart';
import 'widgets/task_style.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskViewModel>().loadTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskViewModel>(
      builder: (context, viewModel, _) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
            elevation: 0,
            scrolledUnderElevation: 0,
            toolbarHeight: 64,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(
                color: isDark ? AppColors.darkBorder : AppColors.border,
                height: 1,
              ),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Task Manager',
                  style: TextStyle(
                    color: isDark ? Colors.white : AppColors.ink,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Plan, track, and sync your work',
                  style: TextStyle(
                    color: isDark ? AppColors.primaryTint : AppColors.muted,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            actions: [
              Material(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.12)
                    : AppColors.primarySoft,
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: viewModel.toggleThemeMode,
                  child: Padding(
                    padding: const EdgeInsets.all(9),
                    child: Icon(
                      isDark
                          ? Icons.dark_mode_rounded
                          : Icons.light_mode_rounded,
                      color: isDark ? Colors.white : AppColors.primary,
                      size: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Material(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.12)
                      : AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: viewModel.isSyncing ? null : viewModel.syncNow,
                    child: Padding(
                      padding: const EdgeInsets.all(9),
                      child: viewModel.isSyncing
                          ? SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: isDark
                                    ? Colors.white
                                    : AppColors.primary,
                              ),
                            )
                          : Icon(
                              Icons.sync_rounded,
                              color: isDark ? Colors.white : AppColors.primary,
                              size: 20,
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              ResponsiveCenter(child: _Header(viewModel: viewModel)),
              Expanded(child: _TaskListBody(viewModel: viewModel)),
            ],
          ),
          floatingActionButton: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.35),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: FloatingActionButton.extended(
              elevation: 0,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const TaskFormScreen()),
                );
              },
              icon: const Icon(Icons.add_rounded, size: 22),
              label: const Text(
                'New task',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.viewModel});

  final TaskViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final completed = viewModel.tasks.where((task) => task.isCompleted).length;
    final pending = viewModel.tasks.length - completed;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isCompact = Responsive.isCompact(context);
    final gap = isCompact ? 8.0 : 12.0;
    final stats = [
      _StatCard(
        label: 'Total',
        value: '${viewModel.tasks.length}',
        icon: Icons.grid_view_rounded,
        accentColor: AppColors.primary,
      ),
      _StatCard(
        label: 'Pending',
        value: '$pending',
        icon: Icons.timer_outlined,
        accentColor: AppColors.warning,
      ),
      _StatCard(
        label: 'Done',
        value: '$completed',
        icon: Icons.check_circle_outline_rounded,
        accentColor: AppColors.teal,
      ),
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        Responsive.horizontalPadding(context),
        16,
        Responsive.horizontalPadding(context),
        20,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.primarySoft,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : AppColors.primary).withValues(
              alpha: 0.08,
            ),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: isCompact ? 70 : 76,
            child: Row(
              children: [
                for (var index = 0; index < stats.length; index++) ...[
                  Expanded(child: stats[index]),
                  if (index != stats.length - 1) SizedBox(width: gap),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          _SyncPill(viewModel: viewModel),
          const SizedBox(height: 16),
          TextField(
            onChanged: viewModel.updateSearch,
            style: TextStyle(
              color: isDark ? Colors.white : AppColors.ink,
              fontSize: 15,
            ),
            decoration: InputDecoration(
              hintText: 'Search by title...',
              hintStyle: TextStyle(
                color: isDark ? AppColors.darkMuted : AppColors.muted,
                fontSize: 14,
              ),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: isDark ? AppColors.darkMuted : AppColors.muted,
                size: 22,
              ),
              filled: true,
              fillColor: isDark ? AppColors.darkBackground : Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(
                  color: isDark ? AppColors.darkBorder : AppColors.border,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(
                  color: isDark ? AppColors.darkBorder : AppColors.border,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          if (isCompact)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildFilterControl(context, isDark),
                const SizedBox(height: 10),
                _buildSortControl(context, isDark, isFullWidth: true),
              ],
            )
          else
            Row(
              children: [
                Expanded(child: _buildFilterControl(context, isDark)),
                const SizedBox(width: 10),
                _buildSortControl(context, isDark),
              ],
            ),
          if (viewModel.errorMessage != null) ...[
            const SizedBox(height: 12),
            _MessagePanel(message: viewModel.errorMessage!),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterControl(BuildContext context, bool isDark) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBackground : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
        ),
      ),
      child: Row(
        children: TaskFilter.values.map((filter) {
          final isSelected = viewModel.filter == filter;
          return Expanded(
            child: GestureDetector(
              onTap: () => viewModel.updateFilter(filter),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  filter.label,
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : (isDark ? Colors.white70 : AppColors.ink),
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSortControl(
    BuildContext context,
    bool isDark, {
    bool isFullWidth = false,
  }) {
    return PopupMenuButton<TaskSort>(
      tooltip: 'Sort',
      initialValue: viewModel.sort,
      onSelected: viewModel.updateSort,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      itemBuilder: (context) => TaskSort.values
          .map(
            (sort) => PopupMenuItem(
              value: sort,
              child: Row(
                children: [
                  Icon(
                    Icons.sort_rounded,
                    size: 18,
                    color: viewModel.sort == sort
                        ? AppColors.primary
                        : AppColors.muted,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    sort.label,
                    style: TextStyle(
                      fontWeight: viewModel.sort == sort
                          ? FontWeight.w700
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
      child: Container(
        height: 44,
        width: isFullWidth ? double.infinity : null,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkBackground : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
          children: [
            Icon(
              Icons.swap_vert_rounded,
              color: isDark ? Colors.white : AppColors.ink,
              size: 20,
            ),
            const SizedBox(width: 6),
            Text(
              viewModel.sort.label,
              style: TextStyle(
                color: isDark ? Colors.white : AppColors.ink,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            if (isFullWidth) const Spacer(),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.accentColor,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isCompact = Responsive.isCompact(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 8 : 10,
        vertical: isCompact ? 8 : 10,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBackground : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
        ),
        boxShadow: isDark
            ? null
            : const [
                BoxShadow(
                  color: AppColors.cardShadow,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(isCompact ? 7 : 8),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: accentColor, size: isCompact ? 17 : 18),
          ),
          SizedBox(width: isCompact ? 8 : 10),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      color: isDark ? Colors.white : AppColors.ink,
                      fontSize: isCompact ? 18 : 20,
                      fontWeight: FontWeight.w900,
                      height: 1.1,
                      letterSpacing: -0.5,
                    ),
                  ),
                  SizedBox(height: isCompact ? 1 : 2),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isDark ? AppColors.darkMuted : AppColors.muted,
                      fontSize: isCompact ? 10 : 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SyncPill extends StatelessWidget {
  const _SyncPill({required this.viewModel});

  final TaskViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final text = viewModel.isOnline
        ? viewModel.pendingSyncCount > 0
              ? '${viewModel.pendingSyncCount} change(s) waiting to sync'
              : 'Online. All changes synced.'
        : 'Offline mode. Changes are saved locally.';
    final color = viewModel.isOnline
        ? AppColors.successBright
        : AppColors.warning;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBackground : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              viewModel.isOnline
                  ? Icons.cloud_done_rounded
                  : Icons.cloud_off_rounded,
              color: color,
              size: 16,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: isDark ? Colors.white : AppColors.ink,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskListBody extends StatelessWidget {
  const _TaskListBody({required this.viewModel});

  final TaskViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    if (viewModel.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    final tasks = viewModel.visibleTasks;
    final horizontalPadding = Responsive.horizontalPadding(context);
    final listPadding = EdgeInsets.fromLTRB(
      horizontalPadding,
      20,
      horizontalPadding,
      96,
    );
    if (tasks.isEmpty) {
      return ListView(
        padding: listPadding,
        children: const [ResponsiveCenter(child: _EmptyState())],
      );
    }

    if (!Responsive.isCompact(context)) {
      return RefreshIndicator(
        color: AppColors.primary,
        onRefresh: viewModel.loadTasks,
        child: GridView.builder(
          padding: listPadding,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: Responsive.isDesktop(context) ? 3 : 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            mainAxisExtent: 210,
          ),
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            return _TaskTile(task: tasks[index], viewModel: viewModel);
          },
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: viewModel.loadTasks,
      child: ListView.separated(
        padding: listPadding,
        itemCount: tasks.length,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (context, index) {
          final task = tasks[index];
          return _TaskTile(task: task, viewModel: viewModel);
        },
      ),
    );
  }
}

class _TaskTile extends StatelessWidget {
  const _TaskTile({required this.task, required this.viewModel});

  final Task task;
  final TaskViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final date = DateFormat('MMM d, yyyy').format(task.dueDate);
    final priorityColor = task.priority.color;

    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: theme.cardColor,
      borderRadius: BorderRadius.circular(22),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => TaskDetailScreen(taskId: task.id),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            boxShadow: const [
              BoxShadow(
                color: AppColors.cardShadow,
                blurRadius: 16,
                offset: Offset(0, 6),
              ),
            ],
          ),
          foregroundDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.border,
            ),
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(width: 8, color: priorityColor),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () => viewModel.toggleCompletion(task),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 26,
                            height: 26,
                            margin: const EdgeInsets.only(top: 2),
                            decoration: BoxDecoration(
                              color: task.isCompleted
                                  ? AppColors.success
                                  : Colors.transparent,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: task.isCompleted
                                    ? AppColors.success
                                    : AppColors.muted.withValues(alpha: 0.5),
                                width: 2,
                              ),
                            ),
                            child: task.isCompleted
                                ? const Icon(
                                    Icons.check_rounded,
                                    size: 16,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                task.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                  color: task.isCompleted
                                      ? AppColors.muted
                                      : AppColors.ink,
                                  decoration: task.isCompleted
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                task.description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: AppColors.muted,
                                  height: 1.35,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 14),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  AppBadge(
                                    label: task.priority.label,
                                    icon: Icons.flag_rounded,
                                    color: priorityColor,
                                  ),
                                  AppBadge(
                                    label: date,
                                    icon: Icons.event_rounded,
                                    color: AppColors.primary,
                                  ),
                                  AppBadge(
                                    label: task.statusLabel,
                                    icon: task.statusIcon,
                                    color: task.statusColor,
                                  ),
                                  if (task.syncStatus != TaskSyncStatus.synced)
                                    const AppBadge(
                                      label: 'Unsynced',
                                      icon: Icons.sync_problem_rounded,
                                      color: AppColors.danger,
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        PopupMenuButton<String>(
                          icon: const Icon(
                            Icons.more_vert_rounded,
                            color: AppColors.muted,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          onSelected: (value) async {
                            if (value == 'edit') {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => TaskFormScreen(task: task),
                                ),
                              );
                            } else if (value == 'delete') {
                              final confirmed =
                                  await showDeleteConfirmationDialog(
                                    context,
                                    task,
                                  );
                              if (confirmed == true) {
                                viewModel.deleteTask(task);
                              }
                            }
                          },
                          itemBuilder: (context) => const [
                            PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit_outlined, size: 18),
                                  SizedBox(width: 8),
                                  Text('Edit'),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.delete_outline_rounded,
                                    size: 18,
                                    color: AppColors.danger,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Delete',
                                    style: TextStyle(color: AppColors.danger),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MessagePanel extends StatelessWidget {
  const _MessagePanel({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AppColors.dangerSoft,
        border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: AppColors.dangerDark,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppColors.dangerText,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return AppPanel(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 64,
            width: 64,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(
              Icons.checklist_rounded,
              color: AppColors.primary,
              size: 34,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No tasks found',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add a task or adjust your search and filters to stay organized.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.muted, fontSize: 14, height: 1.4),
          ),
        ],
      ),
    );
  }
}
