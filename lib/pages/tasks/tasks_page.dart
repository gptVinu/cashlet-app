import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/app_state.dart';
import '../../models/task.dart';
import 'add_task_page.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Today'),
            Tab(text: 'Upcoming'),
            Tab(text: 'Completed'),
          ],
          indicatorSize: TabBarIndicatorSize.tab,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _TasksList(filter: TaskFilter.today),
          _TasksList(filter: TaskFilter.upcoming),
          _TasksList(filter: TaskFilter.completed),
        ],
      ),
    );
  }
}

enum TaskFilter { today, upcoming, completed }

class _TasksList extends StatelessWidget {
  final TaskFilter filter;

  const _TasksList({required this.filter});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    List<Task> tasks;

    // Use the new helper methods from AppState
    switch (filter) {
      case TaskFilter.today:
        tasks = appState.getTodayTasks();
        break;
      case TaskFilter.upcoming:
        tasks = appState.getUpcomingTasks();
        break;
      case TaskFilter.completed:
        tasks = appState.getCompletedTasks();
        break;
    }

    // Sort tasks
    if (filter == TaskFilter.upcoming || filter == TaskFilter.today) {
      // Sort by due date, then by priority (high to low)
      tasks.sort((a, b) {
        final dateComparison = a.dueDate.compareTo(b.dueDate);
        if (dateComparison != 0) return dateComparison;

        // Higher priority value means higher priority
        return b.priority.index.compareTo(a.priority.index);
      });
    } else {
      // For completed tasks, sort by completion date (assuming due date as completed date)
      tasks.sort((a, b) => b.dueDate.compareTo(a.dueDate));
    }

    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.task_alt,
              size: 64,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              filter == TaskFilter.today
                  ? 'No tasks for today'
                  : filter == TaskFilter.upcoming
                      ? 'No upcoming tasks'
                      : 'No completed tasks',
            ),
            if (filter != TaskFilter.completed) ...[
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AddTaskPage()),
                  );
                },
                child: const Text('Add Task'),
              ),
            ],
          ],
        ),
      );
    }

    // Group by date for upcoming tasks
    if (filter == TaskFilter.upcoming) {
      // Group by date
      final Map<String, List<Task>> groupedTasks = {};
      for (var task in tasks) {
        final dateStr = DateFormat('yyyy-MM-dd').format(task.dueDate);

        if (!groupedTasks.containsKey(dateStr)) {
          groupedTasks[dateStr] = [];
        }
        groupedTasks[dateStr]!.add(task);
      }

      // Sort dates
      final sortedDates = groupedTasks.keys.toList()..sort();

      return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: sortedDates.length,
        itemBuilder: (context, index) {
          final date = sortedDates[index];
          final tasksForDate = groupedTasks[date]!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  _formatDate(date),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: tasksForDate.length,
                itemBuilder: (context, i) {
                  return _TaskItem(task: tasksForDate[i]);
                },
              ),
              const Divider(),
            ],
          );
        },
      );
    }

    // Regular list for today and completed
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        return _TaskItem(task: tasks[index]);
      },
    );
  }

  String _formatDate(String dateStr) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = DateTime(now.year, now.month, now.day + 1);

    final date = DateTime.parse(dateStr);
    final taskDate = DateTime(date.year, date.month, date.day);

    if (taskDate == today) {
      return 'Today';
    } else if (taskDate == tomorrow) {
      return 'Tomorrow';
    } else {
      return DateFormat('EEEE, MMMM d')
          .format(date); // e.g., "Monday, January 10"
    }
  }
}

class _TaskItem extends StatelessWidget {
  final Task task;

  const _TaskItem({required this.task});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appState = Provider.of<AppState>(context, listen: false);

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

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: task.isCompleted
              ? Colors.grey.withOpacity(0.3)
              : priorityColor.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          _showTaskDetails(context, task);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
          child: ListTile(
            leading: Checkbox(
              value: task.isCompleted,
              onChanged: (value) {
                appState.toggleTaskCompletion(task.id);
              },
              shape: const CircleBorder(),
            ),
            title: Text(
              task.title,
              style: TextStyle(
                decoration:
                    task.isCompleted ? TextDecoration.lineThrough : null,
                color: task.isCompleted ? theme.disabledColor : null,
                fontWeight: task.isCompleted ? null : FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (task.description != null && task.description!.isNotEmpty)
                  Text(
                    task.description!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: task.isCompleted ? theme.disabledColor : null,
                    ),
                  ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 12,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('MMM d, y').format(task.dueDate),
                      style: theme.textTheme.bodySmall,
                    ),
                    if (task.reminderTime != null) ...[
                      const SizedBox(width: 8),
                      Icon(
                        Icons.notifications_active,
                        size: 12,
                        color: theme.colorScheme.secondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('h:mm a').format(task.reminderTime!),
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ],
            ),
            trailing: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: priorityColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showTaskDetails(BuildContext context, Task task) {
    final appState = Provider.of<AppState>(context, listen: false);
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          maxChildSize: 0.9,
          minChildSize: 0.5,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Task Details',
                          style: theme.textTheme.titleLarge,
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AddTaskPage(task: task),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                Navigator.pop(context);
                                _confirmDelete(context, task);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: 16),
                    Text(
                      task.title,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (task.description != null &&
                        task.description!.isNotEmpty) ...[
                      Text(
                        'Description',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(task.description!),
                      const SizedBox(height: 16),
                    ],
                    Row(
                      children: [
                        Expanded(
                          child: _DetailItem(
                            icon: Icons.calendar_today,
                            title: 'Due Date',
                            value: DateFormat('MMM d, y').format(task.dueDate),
                          ),
                        ),
                        Expanded(
                          child: _DetailItem(
                            icon: Icons.priority_high,
                            title: 'Priority',
                            value: _getPriorityText(task.priority),
                            color: _getPriorityColor(task.priority),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _DetailItem(
                            icon: Icons.repeat,
                            title: 'Repeat',
                            value: _getRepeatText(task.repeatCycle),
                          ),
                        ),
                        Expanded(
                          child: task.reminderTime != null
                              ? _DetailItem(
                                  icon: Icons.notifications_active,
                                  title: 'Reminder',
                                  value: DateFormat('h:mm a')
                                      .format(task.reminderTime!),
                                )
                              : const SizedBox(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          appState.toggleTaskCompletion(task.id);
                          Navigator.pop(context);
                        },
                        child: Text(
                          task.isCompleted
                              ? 'Mark as Incomplete'
                              : 'Mark as Complete',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, Task task) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: Text('Are you sure you want to delete "${task.title}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final appState = Provider.of<AppState>(context, listen: false);
                appState.deleteTask(task.id);
                Navigator.pop(context);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  String _getPriorityText(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return 'High';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.low:
        return 'Low';
    }
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return Colors.red;
      case TaskPriority.medium:
        return Colors.orange;
      case TaskPriority.low:
        return Colors.green;
    }
  }

  String _getRepeatText(TaskRepeatCycle repeatCycle) {
    switch (repeatCycle) {
      case TaskRepeatCycle.none:
        return 'None';
      case TaskRepeatCycle.daily:
        return 'Daily';
      case TaskRepeatCycle.weekly:
        return 'Weekly';
      case TaskRepeatCycle.monthly:
        return 'Monthly';
    }
  }
}

class _DetailItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color? color;

  const _DetailItem({
    required this.icon,
    required this.title,
    required this.value,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleSmall,
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(icon, size: 16, color: color ?? theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
