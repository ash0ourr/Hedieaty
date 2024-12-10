import 'package:flutter/material.dart';

class GiftDetailsPage extends StatefulWidget {
  final String eventId;
  final String? giftId;
  final Map<String, dynamic>? giftData;

  GiftDetailsPage({required this.eventId, this.giftId, this.giftData});

  @override
  _GiftDetailsPageState createState() => _GiftDetailsPageState();
}

class _GiftDetailsPageState extends State<GiftDetailsPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _categoryController;
  late TextEditingController _priceController;

  String _status = 'Available';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.giftData?['name']);
    _descriptionController = TextEditingController(text: widget.giftData?['description']);
    _categoryController = TextEditingController(text: widget.giftData?['category']);
    _priceController = TextEditingController(text: widget.giftData?['price']?.toString());
    _status = widget.giftData?['status'] ?? 'Available';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _saveGift() async {
    if (!_formKey.currentState!.validate()) return;
    // Simulate saving locally
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.giftId == null ? 'Add Gift' : 'Edit Gift')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Gift Name'),
                validator: (value) => value!.isEmpty ? 'Please enter a gift name' : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
              TextFormField(
                controller: _categoryController,
                decoration: InputDecoration(labelText: 'Category'),
              ),
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
              ),
              DropdownButtonFormField<String>(
                value: _status,
                items: ['Available', 'Pledged', 'Purchased']
                    .map((status) => DropdownMenuItem(value: status, child: Text(status)))
                    .toList(),
                onChanged: (value) => setState(() => _status = value!),
                decoration: InputDecoration(labelText: 'Status'),
              ),
              SizedBox(height: 20),
              ElevatedButton(onPressed: _saveGift, child: Text('Save')),
            ],
          ),
        ),
      ),
    );
  }
}