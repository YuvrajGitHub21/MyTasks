import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../application/tasks/task_use_cases.dart';
import '../../../domain/entities/task.dart';
import '../../../app/task_use_case_providers.dart';

class TaskFormScreen extends ConsumerStatefulWidget {
  const TaskFormScreen({this.taskId, super.key});

  final String? taskId;

  @override
  ConsumerState<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends ConsumerState<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _topicController = TextEditingController();
  final _subtopicController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _effortController = TextEditingController(text: '1');

  TaskDate? _startDate = TaskDate.todayInIst();
  TaskDate? _plannedEndDate = TaskDate.todayInIst();
  TaskDate? _maximumEndDate;
  Map<String, String> _errors = const {};
  bool _saving = false;
  bool _loadingExisting = false;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _loadingExisting = widget.taskId != null;
    if (_loadingExisting) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadExistingTask());
    }
  }

  @override
  void dispose() {
    _topicController.dispose();
    _subtopicController.dispose();
    _descriptionController.dispose();
    _effortController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingExisting) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit task')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_loadError != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit task')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(_loadError!, textAlign: TextAlign.center),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.taskId == null ? 'New task' : 'Edit task'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              TextFormField(
                controller: _topicController,
                textCapitalization: TextCapitalization.sentences,
                decoration: _decoration(
                  'Topic *',
                  'Required, up to 200 characters',
                  'topic',
                ),
                maxLength: 200,
                validator: (_) => _errors['topic'],
              ),
              TextFormField(
                controller: _subtopicController,
                textCapitalization: TextCapitalization.sentences,
                decoration: _decoration('Subtopic', 'Optional', 'subtopic'),
                maxLength: 200,
                validator: (_) => _errors['subtopic'],
              ),
              TextFormField(
                controller: _descriptionController,
                textCapitalization: TextCapitalization.sentences,
                decoration: _decoration(
                  'Description',
                  'Optional',
                  'description',
                ),
                maxLines: 3,
                maxLength: 5000,
                validator: (_) => _errors['description'],
              ),
              const SizedBox(height: 8),
              _dateField(
                context,
                label: 'Start date *',
                value: _startDate,
                error: _errors['dates'],
                onChanged: (value) => setState(() => _startDate = value),
              ),
              _dateField(
                context,
                label: 'Planned end date *',
                value: _plannedEndDate,
                error: _errors['dates'] ?? _errors['plannedEndDate'],
                onChanged: (value) => setState(() => _plannedEndDate = value),
                firstDate: _startDate,
              ),
              _dateField(
                context,
                label: 'Maximum end date (optional)',
                value: _maximumEndDate,
                error: _errors['maximumEndDate'],
                onChanged: (value) => setState(() => _maximumEndDate = value),
                allowClear: true,
                firstDate: _plannedEndDate,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _effortController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                ],
                decoration: _decoration(
                  'Estimated effort (hours) *',
                  'Example: 2.5',
                  'effort',
                ),
                validator: (_) => _errors['effort'],
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        widget.taskId == null ? 'Save task' : 'Save changes',
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _decoration(String label, String hint, String field) =>
      InputDecoration(
        labelText: label,
        hintText: hint,
        errorText: _errors[field],
        border: const OutlineInputBorder(),
        alignLabelWithHint: field == 'description',
      );

  Widget _dateField(
    BuildContext context, {
    required String label,
    required TaskDate? value,
    required ValueChanged<TaskDate?> onChanged,
    String? error,
    bool allowClear = false,
    TaskDate? firstDate,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        errorText: error,
        border: const OutlineInputBorder(),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextButton.icon(
              onPressed: () async {
                final initial = value ?? firstDate ?? TaskDate.todayInIst();
                final chosen = await showDatePicker(
                  context: context,
                  initialDate: DateTime(
                    initial.year,
                    initial.month,
                    initial.day,
                  ),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (chosen != null) {
                  onChanged(TaskDate.fromDateTime(chosen));
                }
              },
              icon: const Icon(Icons.calendar_month_outlined),
              label: Text(value?.toStorageString() ?? 'Choose date'),
            ),
          ),
          if (allowClear && value != null)
            IconButton(
              tooltip: 'Clear maximum end date',
              onPressed: () => onChanged(null),
              icon: const Icon(Icons.clear),
            ),
        ],
      ),
    ),
  );

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final input = CreateTaskInput(
        topic: _topicController.text,
        subtopic: _optionalText(_subtopicController.text),
        description: _optionalText(_descriptionController.text),
        startDate: _startDate,
        plannedEndDate: _plannedEndDate,
        maximumEndDate: _maximumEndDate,
        effortInput: _effortController.text,
      );
      if (widget.taskId == null) {
        final createTask = await ref.read(createTaskUseCaseProvider.future);
        await createTask(input);
      } else {
        final updateTask = await ref.read(updateTaskUseCaseProvider.future);
        final updated = await updateTask(
          UpdateTaskInput(
            taskId: widget.taskId!,
            topic: input.topic,
            subtopic: input.subtopic,
            description: input.description,
            startDate: input.startDate,
            plannedEndDate: input.plannedEndDate,
            maximumEndDate: input.maximumEndDate,
            effortInput: input.effortInput,
          ),
        );
        if (!updated) {
          _showMessage('This task is no longer available.');
          return;
        }
        ref.invalidate(taskDetailsProvider(widget.taskId!));
      }
      if (mounted) Navigator.of(context).pop();
    } on TaskValidationException catch (error) {
      setState(() => _errors = error.errors);
      _formKey.currentState?.validate();
    } catch (error) {
      _showMessage('Could not save task: $error');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _loadExistingTask() async {
    try {
      final task = await ref.read(taskDetailsProvider(widget.taskId!).future);
      if (task == null) throw StateError('This task is no longer available.');
      if (!mounted) return;
      setState(() {
        _topicController.text = task.topic;
        _subtopicController.text = task.subtopic ?? '';
        _descriptionController.text = task.description ?? '';
        _effortController.text = _formatEffort(task.effortHundredths);
        _startDate = task.startDate;
        _plannedEndDate = task.plannedEndDate;
        _maximumEndDate = task.maximumEndDate;
        _loadingExisting = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loadError = 'Could not load this task: $error';
        _loadingExisting = false;
      });
    }
  }

  String _formatEffort(int hundredths) {
    final hours = hundredths ~/ 100;
    final fraction = hundredths % 100;
    return fraction == 0
        ? '$hours'
        : '$hours.${fraction.toString().padLeft(2, '0').replaceFirst(RegExp(r'0+$'), '')}';
  }

  String? _optionalText(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}
