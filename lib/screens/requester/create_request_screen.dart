import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/request_model.dart';
import '../../utils/english_text.dart';
import '../../providers/app_state.dart';
import '../../utils/theme.dart';
import '../../widgets/loading_overlay.dart';
import '../../widgets/location_picker_map.dart';

class CreateRequestScreen extends StatefulWidget {
  const CreateRequestScreen({super.key});

  @override
  State<CreateRequestScreen> createState() => _CreateRequestScreenState();
}

class _CreateRequestScreenState extends State<CreateRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();

  final _proxyNameController = TextEditingController();
  final _proxyNotesController = TextEditingController();

  RequestCategory _category = RequestCategory.groceries;
  RequestUrgency _urgency = RequestUrgency.medium;
  DateTime _preferredTime = DateTime.now().add(const Duration(hours: 2));
  bool _isLoading = false;
  bool _isProxy = false;
  LocationPickerResult? _pickedLocation;
  String _proxyRelationship = 'grandparent';

  @override
  void dispose() {
    _descriptionController.dispose();

    _proxyNameController.dispose();
    _proxyNotesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_descriptionController.text.trim().length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('The description must be at least 10 characters'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    if (_pickedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a location on the map'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    if (_preferredTime.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Date and time must be in the future'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    if (_isProxy) {
      if (_proxyNameController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Enter the name of the person you are requesting help for',
            ),
            backgroundColor: AppTheme.errorColor,
          ),
        );
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      final appState = context.read<AppState>();
      await appState.createRequest(
        category: _category,
        description: _descriptionController.text.trim(),
        urgency: _urgency,
        location: _pickedLocation!.addressText,
        latitude: _pickedLocation!.latitude,
        longitude: _pickedLocation!.longitude,
        preferredTime: _preferredTime,
        isProxy: _isProxy,
        proxyForName: _isProxy ? _proxyNameController.text.trim() : null,
        proxyRelationship: _isProxy ? _proxyRelationship : null,
        proxyNotes: _isProxy && _proxyNotesController.text.trim().isNotEmpty
            ? _proxyNotesController.text.trim()
            : null,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Request created successfully!'),
            backgroundColor: AppTheme.secondaryColor,
            duration: Duration(seconds: 2),
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(friendlyErrorMessage(e.toString())),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isLoading,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Create request'),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'How can we help?',
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: 24),
              Text(
                'What kind of help',
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: RequestCategory.values.map((category) {
                  final isSelected = _category == category;
                  return ChoiceChip(
                    label: Text(category.label),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() => _category = category);
                    },
                    selectedColor: AppTheme.primaryColor.withValues(alpha: 0.2),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'e.g. I need bread, milk, and eggs',
                  helperText: 'Minimum 10 characters',
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Description is required';
                  }
                  if (value.trim().length < 10) {
                    return 'Minimum 10 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () async {
                  final result =
                      await Navigator.of(context).push<LocationPickerResult>(
                    MaterialPageRoute(
                      builder: (_) =>
                          LocationPickerMap(initial: _pickedLocation),
                    ),
                  );
                  if (result != null) {
                    setState(() => _pickedLocation = result);
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _pickedLocation == null
                          ? Theme.of(context).colorScheme.outline
                          : AppTheme.primaryColor,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: _pickedLocation == null
                            ? AppTheme.textSecondary
                            : AppTheme.primaryColor,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _pickedLocation == null
                            ? Text(
                                'Tap to select location on map',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(
                                      color: AppTheme.textSecondary,
                                    ),
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _pickedLocation!.addressText,
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${_pickedLocation!.latitude.toStringAsFixed(5)}, '
                                    '${_pickedLocation!.longitude.toStringAsFixed(5)}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall!
                                        .copyWith(
                                          color: AppTheme.textSecondary,
                                        ),
                                  ),
                                ],
                              ),
                      ),
                      const Icon(Icons.chevron_right,
                          size: 18, color: AppTheme.textSecondary),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'How urgent is it?',
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: RequestUrgency.values.map((urgency) {
                  final isSelected = _urgency == urgency;
                  return ChoiceChip(
                    label: Text(urgency.label),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() => _urgency = urgency);
                    },
                    selectedColor:
                        AppTheme.getUrgencyColor(urgency)
                            .withValues(alpha: 0.2),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              Text(
                'When would you like it?',
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.access_time),
                  title: Text(
                    formatDateTimeText(_preferredTime),
                  ),
                  trailing: const Icon(Icons.edit),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _preferredTime,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 30)),
                    );
                    if (date != null) {
                      if (!context.mounted) return;
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(_preferredTime),
                      );
                      if (time != null) {
                        setState(() {
                          _preferredTime = DateTime(
                            date.year,
                            date.month,
                            date.day,
                            time.hour,
                            time.minute,
                          );
                        });
                      }
                    }
                  },
                ),
              ),
              const SizedBox(height: 24),
              Card(
                color: AppTheme.primaryColor.withValues(alpha: 0.05),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'It is for someone else',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                          Switch(
                            value: _isProxy,
                            onChanged: (value) {
                              setState(() => _isProxy = value);
                            },
                          ),
                        ],
                      ),
                      if (_isProxy) ...[
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _proxyNameController,
                          decoration: const InputDecoration(
                            labelText: 'Person’s name',
                            hintText: 'e.g. Maria Popescu',
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          validator: (value) {
                            if (_isProxy &&
                                (value == null || value.trim().isEmpty)) {
                              return 'Name is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          initialValue: _proxyRelationship,
                          decoration: const InputDecoration(
                            labelText: 'Relationship',
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          items: const [
                            DropdownMenuItem(
                                value: 'grandparent',
                                child: Text('Grandparent')),
                            DropdownMenuItem(
                                value: 'parent',
                                child: Text('Parent')),
                            DropdownMenuItem(
                                value: 'neighbor',
                                child: Text('Neighbor')),
                            DropdownMenuItem(
                                value: 'patient',
                                child: Text('Patient')),
                            DropdownMenuItem(
                                value: 'friend',
                                child: Text('Friend')),
                            DropdownMenuItem(
                                value: 'other',
                                child: Text('Other')),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _proxyRelationship = value);
                            }
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _proxyNotesController,
                          decoration: const InputDecoration(
                            labelText: 'Notes (optional)',
                            hintText: 'e.g. hard of hearing, does not have a phone',
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          maxLines: 2,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  child: const Text('Create request'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
