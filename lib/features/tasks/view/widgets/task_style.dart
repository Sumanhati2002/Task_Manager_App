import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../model/task.dart';

extension TaskPriorityStyle on TaskPriority {
  Color get color {
    switch (this) {
      case TaskPriority.low:
        return AppColors.teal;
      case TaskPriority.medium:
        return AppColors.warning;
      case TaskPriority.high:
        return AppColors.danger;
    }
  }
}

extension TaskStatusStyle on Task {
  String get statusLabel => isCompleted ? 'Completed' : 'Pending';

  IconData get statusIcon {
    return isCompleted
        ? Icons.check_circle_rounded
        : Icons.hourglass_top_rounded;
  }

  Color get statusColor {
    return isCompleted ? AppColors.success : AppColors.warning;
  }
}
