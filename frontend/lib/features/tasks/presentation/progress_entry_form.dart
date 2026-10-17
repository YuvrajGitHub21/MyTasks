import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/progress_use_case_providers.dart';
import '../../../application/progress/progress_use_cases.dart';
import '../../../domain/entities/progress_entry.dart';

class ProgressEntryForm extends ConsumerStatefulWidget {
  const ProgressEntryForm({required this.taskId, super.key});

  final String taskId;

  @override
  ConsumerState<ProgressEntryForm> createState() => _ProgressEntryFormState();
}

class _ProgressEntryFormState extends ConsumerState<ProgressEntryForm> {
  final _formKey = GlobalKey<FormState>();
  final _percentController = TextEditingController();
  final _completedUnitsController = TextEditingController();
  final _totalUnitsController = TextEditingController();
  final _noteController = TextEditingController();
  ProgressMethod _method = ProgressMethod.percent;
  bool _saving = false;
  String? _saveError;

  @override
  void dispose() {
    _percentController.dispose();
    _completedUnitsController.dispose();
    _totalUnitsController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(
      20,
      20,
      20,
      20 + MediaQuery.viewInsetsOf(context).bottom,
    ),
    child: Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Log partial progress',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<ProgressMethod>(
              initialValue: _method,
              decoration: const InputDecoration(labelText: 'Progress method'),
              items: const [
                DropdownMenuItem(
                  value: ProgressMethod.percent,
                  child: Text('Percentage'),
                ),
                DropdownMenuItem(
                  value: ProgressMethod.units,
                  child: Text('Completed units'),
                ),
                DropdownMenuItem(
                  value: ProgressMethod.note,
                  child: Text('Note'),
                ),
              ],
              onChanged: _saving
                  ? null
                  : (method) {
                      if (method == null) return;
                      setState(() {
                        _method = method;
                        _saveError = null;
                      });
                    },
            ),
            const SizedBox(height: 12),
            if (_method == ProgressMethod.percent)
              TextFormField(
                controller: _percentController,
                enabled: !_saving,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Percentage complete',
                  suffixText: '%',
                ),
                validator: (value) {
                  final number = int.tryParse(value?.trim() ?? '');
                  return number == null || number < 0 || number > 100
                      ? 'Enter a percentage from 0 to 100.'
                      : null;
                },
              ),
            if (_method == ProgressMethod.units) ...[
              TextFormField(
                controller: _completedUnitsController,
                enabled: !_saving,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Completed units'),
                validator: (value) => _positiveIntegerError(value),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _totalUnitsController,
                enabled: !_saving,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Total units'),
                validator: (value) {
                  final total = int.tryParse(value?.trim() ?? '');
                  final completed = int.tryParse(
                    _completedUnitsController.text.trim(),
                  );
                  if (total == null || total <= 0) {
                    return 'Enter a positive total number of units.';
                  }
                  if (completed != null && completed > total) {
                    return 'Total units must be at least completed units.';
                  }
                  return null;
                },
              ),
            ],
            if (_method == ProgressMethod.note)
              TextFormField(
                controller: _noteController,
                enabled: !_saving,
                minLines: 3,
                maxLines: 5,
                maxLength: 2000,
                decoration: const InputDecoration(
                  labelText: 'What did you work on?',
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  final note = value?.trim() ?? '';
                  return note.isEmpty || note.length > 2000
                      ? 'Enter a progress note of up to 2,000 characters.'
                      : null;
                },
              ),
            if (_saveError case final error?) ...[
              const SizedBox(height: 8),
              Text(
                error,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save progress'),
            ),
          ],
        ),
      ),
    ),
  );

  String? _positiveIntegerError(String? value) {
    final number = int.tryParse(value?.trim() ?? '');
    return number == null || number <= 0
        ? 'Enter a positive whole number.'
        : null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _saveError = null;
    });

    final input = RecordProgressInput(
      taskId: widget.taskId,
      method: _method,
      percentComplete: _method == ProgressMethod.percent
          ? int.parse(_percentController.text.trim())
          : null,
      completedUnits: _method == ProgressMethod.units
          ? int.parse(_completedUnitsController.text.trim())
          : null,
      totalUnits: _method == ProgressMethod.units
          ? int.parse(_totalUnitsController.text.trim())
          : null,
      note: _method == ProgressMethod.note ? _noteController.text.trim() : null,
    );

    try {
      final recordProgress = await ref.read(
        recordProgressUseCaseProvider.future,
      );
      await recordProgress(input);
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _saveError = error is ProgressValidationException
            ? error.errors.values.join('\n')
            : 'Could not save progress: $error';
      });
    }
  }
}
