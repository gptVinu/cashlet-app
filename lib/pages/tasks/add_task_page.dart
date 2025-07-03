import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/app_state.dart';
import '../../models/task.dart';
import '../../services/notification_service.dart';
import '../../services/storage_service.dart';

class AddTaskPage extends StatefulWidget {
  final Task? task; // If editing existing task

  const AddTaskPage({super.key, this.task});

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  DateTime _selectedDate = DateTime.now();
  DateTime? _selectedReminderTime;
  TaskPriority _selectedPriority = TaskPriority.medium;
  TaskRepeatCycle _selectedRepeatCycle = TaskRepeatCycle.none;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  bool get _isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descriptionController = TextEditingController(
      text: widget.task?.description ?? '',
    );

    if (_isEditing) {
      _selectedDate = widget.task!.dueDate;
      _selectedReminderTime = widget.task!.reminderTime;
      _selectedPriority = widget.task!.priority;
      _selectedRepeatCycle = widget.task!.repeatCycle;
    }

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Task' : 'Add Task'),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.title),
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description (Optional)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.description),
                  ),
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () => _selectDate(context),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Due Date',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text(
                      DateFormat('dd/MM/yyyy').format(_selectedDate),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Priority',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _PriorityOption(
                      label: 'Low',
                      color: Colors.green,
                      isSelected: _selectedPriority == TaskPriority.low,
                      onTap: () {
                        setState(() {
                          _selectedPriority = TaskPriority.low;
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    _PriorityOption(
                      label: 'Medium',
                      color: Colors.orange,
                      isSelected: _selectedPriority == TaskPriority.medium,
                      onTap: () {
                        setState(() {
                          _selectedPriority = TaskPriority.medium;
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    _PriorityOption(
                      label: 'High',
                      color: Colors.red,
                      isSelected: _selectedPriority == TaskPriority.high,
                      onTap: () {
                        setState(() {
                          _selectedPriority = TaskPriority.high;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Repeat',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<TaskRepeatCycle>(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.repeat),
                  ),
                  value: _selectedRepeatCycle,
                  items: TaskRepeatCycle.values.map((cycle) {
                    String label;
                    switch (cycle) {
                      case TaskRepeatCycle.none:
                        label = 'None';
                        break;
                      case TaskRepeatCycle.daily:
                        label = 'Daily';
                        break;
                      case TaskRepeatCycle.weekly:
                        label = 'Weekly';
                        break;
                      case TaskRepeatCycle.monthly:
                        label = 'Monthly';
                        break;
                    }
                    return DropdownMenuItem(
                      value: cycle,
                      child: Text(label),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedRepeatCycle = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Set Reminder',
                      style: theme.textTheme.titleMedium,
                    ),
                    Switch(
                      value: _selectedReminderTime != null,
                      onChanged: (value) {
                        setState(() {
                          if (value) {
                            // Default reminder time to 9:00 AM on the due date
                            _selectedReminderTime = DateTime(
                              _selectedDate.year,
                              _selectedDate.month,
                              _selectedDate.day,
                              9, // 9 AM
                              0, // 0 minutes
                            );
                          } else {
                            _selectedReminderTime = null;
                          }
                        });
                      },
                    ),
                  ],
                ),
                if (_selectedReminderTime != null) ...[
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () => _selectTime(context),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Reminder Time',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.access_time),
                      ),
                      child: Text(
                        DateFormat('h:mm a').format(_selectedReminderTime!),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: _saveTask,
                    child: Text(
                      _isEditing ? 'Update' : 'Save',
                      style: const TextStyle(fontSize: 16),
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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;

        // Update reminder time date if set
        if (_selectedReminderTime != null) {
          _selectedReminderTime = DateTime(
            picked.year,
            picked.month,
            picked.day,
            _selectedReminderTime!.hour,
            _selectedReminderTime!.minute,
          );
        }
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedReminderTime!),
    );

    if (picked != null) {
      setState(() {
        _selectedReminderTime = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  void _saveTask() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();

    final appState = Provider.of<AppState>(context, listen: false);

    Task task;
    if (_isEditing) {
      task = widget.task!.copyWith(
        title: title,
        description: description.isEmpty ? null : description,
        dueDate: _selectedDate,
        priority: _selectedPriority,
        repeatCycle: _selectedRepeatCycle,
        reminderTime: _selectedReminderTime,
      );

      appState.updateTask(task);
    } else {
      task = Task(
        title: title,
        description: description.isEmpty ? null : description,
        dueDate: _selectedDate,
        priority: _selectedPriority,
        repeatCycle: _selectedRepeatCycle,
        reminderTime: _selectedReminderTime,
      );

      appState.addTask(task);
    }

    // Set notification for task if reminder is set
    // if (_selectedReminderTime != null) {
    //   // Cancel any existing notification for this task
    //   if (_isEditing) {
    //     await NotificationService()
    //         .cancelNotification(int.parse(widget.task!.id.split('-').first));
    //   }

    //   // Schedule new notification
    //   int notificationId = int.parse(task.id
    //       .split('-')
    //       .first); // Use first part of UUID as notification ID
    //   await NotificationService().scheduleNotification(
    //     id: notificationId,
    //     title: 'Cashlet Task Reminder',
    //     body: title,
    //     scheduledDate: _selectedReminderTime!,
    //   );
    // }

    Navigator.pop(context);

    // Save to local storage
    await StorageService().saveAllData(
      expenses: appState.expenses,
      tasks: appState.tasks,
      categories: appState.categories,
      budgets: appState.budgets,
    );
  }
}

class _PriorityOption extends StatelessWidget {
  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _PriorityOption({
    required this.label,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.2) : Colors.transparent,
            border: Border.all(
              color: isSelected ? color : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? color : null,
                  fontWeight: isSelected ? FontWeight.bold : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
