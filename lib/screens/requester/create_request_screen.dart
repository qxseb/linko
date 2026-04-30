import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/request_model.dart';
import '../../providers/app_state.dart';
import '../../utils/theme.dart';
import '../../widgets/loading_overlay.dart';

class CreateRequestScreen extends StatefulWidget {
  const CreateRequestScreen({super.key});

  @override
  State<CreateRequestScreen> createState() => _CreateRequestScreenState();
}

class _CreateRequestScreenState extends State<CreateRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _proxyNameController = TextEditingController();
  final _proxyNotesController = TextEditingController();

  RequestCategory _category = RequestCategory.groceries;
  RequestUrgency _urgency = RequestUrgency.medium;
  DateTime _preferredTime = DateTime.now().add(const Duration(hours: 2));
  bool _isLoading = false;
  bool _isProxy = false;
  String _proxyRelationship = 'Bunică/Bunic';

  @override
  void dispose() {
    _descriptionController.dispose();
    _locationController.dispose();
    _proxyNameController.dispose();
    _proxyNotesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_descriptionController.text.trim().length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Descrierea trebuie să aibă minim 10 caractere'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    if (_locationController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Introdu locația'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    if (_preferredTime.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data și ora trebuie să fie în viitor'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    if (_isProxy) {
      if (_proxyNameController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Introdu numele persoanei pentru care ceri ajutor'),
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
        location: _locationController.text.trim(),
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
            content: Text('Cerere creată cu succes!'),
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
            content: Text('Eroare: ${e.toString()}'),
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
          title: const Text('Creează cerere'),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Cu ce te putem ajuta?',
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: 24),
              Text(
                'Ce fel de ajutor',
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
                    label: Text(_getCategoryLabel(category)),
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
                  labelText: 'Descriere',
                  hintText: 'ex: Am nevoie de pâine, lapte și ouă',
                  helperText: 'Minim 10 caractere',
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Descrierea este obligatorie';
                  }
                  if (value.trim().length < 10) {
                    return 'Minim 10 caractere';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Locație',
                  hintText: 'ex: Farmacia Catena, Str. Dorobanți',
                  prefixIcon: Icon(Icons.location_on),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Locația este obligatorie';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Text(
                'Cât de urgent',
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
                    label: Text(_getUrgencyLabel(urgency)),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() => _urgency = urgency);
                    },
                    selectedColor:
                        AppTheme.getUrgencyColor(_getUrgencyLabel(urgency))
                            .withValues(alpha: 0.2),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              Text(
                'Când ai vrea',
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.access_time),
                  title: Text(
                    '${_preferredTime.day}/${_preferredTime.month}/${_preferredTime.year} la ${_preferredTime.hour}:${_preferredTime.minute.toString().padLeft(2, '0')}',
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
                              'E pentru altcineva',
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
                            labelText: 'Numele persoanei',
                            hintText: 'ex: Maria Popescu',
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          validator: (value) {
                            if (_isProxy &&
                                (value == null || value.trim().isEmpty)) {
                              return 'Numele este obligatoriu';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          initialValue: _proxyRelationship,
                          decoration: const InputDecoration(
                            labelText: 'Relație',
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          items: const [
                            DropdownMenuItem(
                                value: 'Bunică/Bunic',
                                child: Text('Bunică/Bunic')),
                            DropdownMenuItem(
                                value: 'Părinte', child: Text('Părinte')),
                            DropdownMenuItem(
                                value: 'Vecin', child: Text('Vecin')),
                            DropdownMenuItem(
                                value: 'Pacient', child: Text('Pacient')),
                            DropdownMenuItem(
                                value: 'Prieten', child: Text('Prieten')),
                            DropdownMenuItem(
                                value: 'Altceva', child: Text('Altceva')),
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
                            labelText: 'Notițe (opțional)',
                            hintText: 'ex: nu aude bine, n-are telefon',
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
                  child: const Text('Creează cerere'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getCategoryLabel(RequestCategory category) {
    switch (category) {
      case RequestCategory.groceries:
        return 'Cumpărături';
      case RequestCategory.pharmacy:
        return 'Farmacie';
      case RequestCategory.errands:
        return 'Treburi';
      case RequestCategory.checkIn:
        return 'Verificare';
    }
  }

  String _getUrgencyLabel(RequestUrgency urgency) {
    switch (urgency) {
      case RequestUrgency.low:
        return 'Normală';
      case RequestUrgency.medium:
        return 'Medie';
      case RequestUrgency.high:
        return 'Urgentă';
    }
  }
}
