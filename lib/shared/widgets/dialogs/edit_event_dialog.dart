import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../features/events/domain/entities/event.dart';
import '../../../features/events/presentation/providers/event_providers.dart';

class EditEventDialog extends ConsumerStatefulWidget {
  const EditEventDialog({super.key, required this.event});
  final Event event;

  static Future<void> show(BuildContext context, Event event) {
    return showDialog(
      context: context,
      builder: (context) => EditEventDialog(event: event),
    );
  }

  @override
  ConsumerState<EditEventDialog> createState() => _EditEventDialogState();
}

class _EditEventDialogState extends ConsumerState<EditEventDialog> {
  late final TextEditingController _nameController;
  late DateTime _selectedDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.event.name);
    _selectedDate = widget.event.date;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty) return;
    setState(() => _isLoading = true);

    try {
      final updatedEvent = Event(
        id: widget.event.id,
        name: _nameController.text.trim(),
        date: _selectedDate,
        tierId: widget.event.tierId,
        organizerId: widget.event.organizerId,
        joinCode: widget.event.joinCode,
        maxPhotos: widget.event.maxPhotos,
        qrData: widget.event.qrData,
        photoCount: widget.event.photoCount,
        attendeeCount: widget.event.attendeeCount,
        storageBytes: widget.event.storageBytes,
      );
      await ref.read(eventRepositoryProvider).updateEvent(updatedEvent);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update event: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Event'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Event Name'),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Event Date'),
            subtitle: Text(DateFormat.yMMMd().format(_selectedDate)),
            trailing: const Icon(Icons.calendar_today),
            onTap: _pickDate,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _save,
          child: _isLoading 
            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) 
            : const Text('Save'),
        ),
      ],
    );
  }
}
