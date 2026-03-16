import 'package:flutter/material.dart';
import 'package:test_app/domain/entities/recurrence.dart';

class RecurrencePicker extends StatefulWidget {
  const RecurrencePicker({
    super.key,
    this.initialRecurrence,
    required this.onChanged,
  });

  final Recurrence? initialRecurrence;
  final ValueChanged<Recurrence?> onChanged;

  @override
  State<RecurrencePicker> createState() => _RecurrencePickerState();
}

class _RecurrencePickerState extends State<RecurrencePicker> {
  bool _enabled = false;
  RecurrenceType _type = RecurrenceType.daily;
  int _interval = 1;
  List<int> _weekdays = [];
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    final r = widget.initialRecurrence;
    if (r != null) {
      _enabled = true;
      _type = r.type;
      _interval = r.interval;
      _weekdays = r.weekdays ?? [];
      _endDate = r.endDate;
    }
  }

  void _notify() {
    if (!_enabled) {
      widget.onChanged(null);
      return;
    }
    widget.onChanged(
      Recurrence(
        type: _type,
        interval: _interval,
        weekdays: (_type == RecurrenceType.weekly ||
                _type == RecurrenceType.custom)
            ? (_weekdays.isEmpty ? null : _weekdays)
            : null,
        endDate: _endDate,
      ),
    );
  }

  Widget _buildWeekdaySelector() {
    const dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return Wrap(
      spacing: 4,
      children: List.generate(7, (index) {
        final day = index + 1; // 1=Mon..7=Sun
        final selected = _weekdays.contains(day);
        return FilterChip(
          label: Text(dayLabels[index]),
          selected: selected,
          onSelected: (value) {
            setState(() {
              if (value) {
                _weekdays = [..._weekdays, day]..sort();
              } else {
                _weekdays = _weekdays.where((d) => d != day).toList();
              }
            });
            _notify();
          },
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile(
          title: const Text('Repeat'),
          value: _enabled,
          onChanged: (value) {
            setState(() => _enabled = value);
            _notify();
          },
          contentPadding: EdgeInsets.zero,
        ),
        if (_enabled) ...[
          DropdownButtonFormField<RecurrenceType>(
            initialValue: _type,
            decoration: const InputDecoration(labelText: 'Recurrence type'),
            items: RecurrenceType.values
                .map(
                  (t) => DropdownMenuItem(
                    value: t,
                    child: Text(
                      t.name[0].toUpperCase() + t.name.substring(1),
                    ),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _type = value);
                _notify();
              }
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            initialValue: _interval.toString(),
            decoration: const InputDecoration(
              labelText: 'Every N intervals',
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              final parsed = int.tryParse(value);
              if (parsed != null && parsed > 0) {
                _interval = parsed;
                _notify();
              }
            },
          ),
          if (_type == RecurrenceType.weekly ||
              _type == RecurrenceType.custom) ...[
            const SizedBox(height: 12),
            const Text('Weekdays'),
            const SizedBox(height: 4),
            _buildWeekdaySelector(),
          ],
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              _endDate != null
                  ? 'End date: ${_endDate!.toLocal().toString().split(' ')[0]}'
                  : 'No end date',
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_endDate != null)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      setState(() => _endDate = null);
                      _notify();
                    },
                  ),
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _endDate ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate:
                          DateTime.now().add(const Duration(days: 3650)),
                    );
                    if (picked != null) {
                      setState(() => _endDate = picked);
                      _notify();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
