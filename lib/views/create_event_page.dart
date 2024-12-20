import 'package:flutter/material.dart';
import 'package:project/controllers/event_controller.dart';
import 'package:project/models/EventModel.dart';

// CreateEventPage keys
final Key _eventNameFieldKey = Key('eventNameField');
final Key _eventDescriptionFieldKey = Key('eventDescriptionField');
final Key _eventLocationFieldKey = Key('eventLocationField');
final Key _eventDateFieldKey = Key('eventDateField');
final Key _eventDatePickerButtonKey = Key('eventDatePickerButton'); // Added key for date picker button
final Key _saveEventButtonKey = Key('saveEventButton');
final Key _backButtonKey = Key('backButton'); // Added unique key for back button

class CreateEventPage extends StatefulWidget {
  final String currentUserId;

  const CreateEventPage({Key? key, required this.currentUserId}) : super(key: key);

  @override
  State<CreateEventPage> createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> with SingleTickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  DateTime? _selectedDate;
  final EventController _eventController = EventController();

  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeInAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    _animationController.forward();
  }

  Future<void> _saveEvent() async {
    if (_nameController.text.isEmpty || _selectedDate == null || _locationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields and select a date')),
      );
      return;
    }

    final newEvent = EventModel(
      id: '',
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      date: _selectedDate!,
      location: _locationController.text.trim(),
    );

    await _eventController.createEvent(widget.currentUserId, newEvent);
    Navigator.pop(context); // Redirect back to EventListPage
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Event'),
        backgroundColor: Colors.pinkAccent,
        leading: IconButton(
          key: _backButtonKey, // Use unique key for back button
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeInAnimation,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              TextField(
                key: _eventNameFieldKey,
                controller: _nameController,
                decoration: _inputDecoration('Event Name'),
              ),
              const SizedBox(height: 16.0),
              TextField(
                key: _eventDescriptionFieldKey,
                controller: _descriptionController,
                decoration: _inputDecoration('Event Description'),
                maxLines: 3,
              ),
              const SizedBox(height: 16.0),
              TextField(
                key: _eventLocationFieldKey,
                controller: _locationController,
                decoration: _inputDecoration('Event Location'),
              ),
              const SizedBox(height: 16.0),
              _buildDateSelector(),
              const SizedBox(height: 24.0),
              ElevatedButton.icon(
                key: _saveEventButtonKey, // Ensure this key is used for the save event button
                onPressed: _saveEvent,
                icon: const Icon(Icons.save),
                label: const Text('Save Event'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pinkAccent,
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateSelector() {
    return Row(
      children: [
        Expanded(
          child: Text(
            _selectedDate == null
                ? 'No Date Selected'
                : 'Date: ${_selectedDate!.toLocal()}'.split(' ')[0],
          ),
        ),
        ElevatedButton(
          key: _eventDatePickerButtonKey, // Added key for date picker button
          onPressed: () async {
            final pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (pickedDate != null) {
              setState(() {
                _selectedDate = pickedDate;
              });
            }
          },
          child: const Text('Select Date'),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.pinkAccent, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }
}
