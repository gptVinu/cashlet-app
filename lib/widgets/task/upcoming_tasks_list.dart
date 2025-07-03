import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/app_state.dart';
import '../../models/task.dart';
import 'package:cashlet/pages/tasks/add_task_page.dart';

class UpcomingTasksList extends StatelessWidget {
  final int limit;
  const UpcomingTasksList({Key? key, this.limit = 3}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    // Get tasks for the next 7 days
    final upcomingTasks = appState.getTasksForNextDays(7);

    if (upcomingTasks.isEmpty) {
      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 48,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 8),
              const Text('No upcoming tasks'),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AddTaskPage()),
                  );
                },
                child: const Text('Add a new task'),
              ),
            ],
          ),
        ),
      );
    }

    // Sort tasks by due date and priority
    upcomingTasks.sort((a, b) {
      final dateComparison = a.dueDate.compareTo(b.dueDate);
      if (dateComparison != 0) return dateComparison;

      // Higher priority value means higher priority
      return b.priority.index.compareTo(a.priority.index);
    });

    // Take only the first [limit] tasks
    final displayTasks = upcomingTasks.take(limit).toList();

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: displayTasks.length,
      itemBuilder: (context, index) {
        final task = displayTasks[index];
        return _TaskItem(task: task);
      },
    );
  }
}

class _TaskItem extends StatelessWidget {
  final Task task;

  const _TaskItem({required this.task});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Priority color
    Color priorityColor;
    switch (task.priority) {
      case TaskPriority.high:
        priorityColor = Colors.red;
        break;
      case TaskPriority.medium:
        priorityColor = Colors.orange;
        break;
      case TaskPriority.low:
        priorityColor = Colors.green;
        break;
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = DateTime(today.year, today.month, today.day + 1);
    final taskDate =
        DateTime(task.dueDate.year, task.dueDate.month, task.dueDate.day);

    String dateText;
    if (taskDate == today) {
      dateText = 'Today';
    } else if (taskDate == tomorrow) {
      dateText = 'Tomorrow';
    } else {
      dateText = DateFormat('MMM d').format(task.dueDate);
    }

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: priorityColor.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 50,
              decoration: BoxDecoration(
                color: priorityColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (task.description != null &&
                      task.description!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      task.description!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    dateText,
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (task.reminderTime != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 12,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('h:mm a').format(task.reminderTime!),
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
