import 'package:flutter/material.dart';
import 'package:project/models/GiftModel.dart';
import 'package:project/controllers/gift_controller.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class GiftDetailsPage extends StatefulWidget {
  final String userId;
  final String eventId;
  final GiftModel? gift;

  const GiftDetailsPage({
    Key? key,
    required this.userId,
    required this.eventId,
    this.gift,
  }) : super(key: key);

  @override
  State<GiftDetailsPage> createState() => _GiftDetailsPageState();
}

class _GiftDetailsPageState extends State<GiftDetailsPage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final GiftController _giftController = GiftController();

  late TextEditingController _nameController;
  late TextEditingController _categoryController;
  late TextEditingController _priceController;
  late TextEditingController _descriptionController;

  String _status = 'Available';
  File? _image;
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.gift?.name ?? '');
    _categoryController = TextEditingController(text: widget.gift?.category ?? '');
    _priceController =
        TextEditingController(text: widget.gift?.price.toStringAsFixed(2) ?? '');
    _descriptionController =
        TextEditingController(text: widget.gift?.description ?? '');
    _status = widget.gift?.status ?? 'Available';

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeInAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _animationController.forward();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveGift() async {
    if (_formKey.currentState!.validate()) {
      final gift = GiftModel(
        id: widget.gift?.id ?? '',
        name: _nameController.text.trim(),
        category: _categoryController.text.trim(),
        price: double.tryParse(_priceController.text) ?? 0.0,
        description: _descriptionController.text.trim(),
        status: _status,
        pledged: widget.gift?.pledged ?? false,
        purchased: widget.gift?.purchased ?? false,
        eventId: widget.eventId, // Ensure eventId is included
        date: widget.gift?.date ?? DateTime.now(), // Ensure date is included
      );

      if (widget.gift == null) {
        await _giftController.addGift(widget.eventId, widget.userId, gift);
      } else {
        await _giftController.updateGift(
            widget.userId, widget.eventId, gift.id, gift.toMap());
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.gift == null ? 'Add Gift' : 'Edit Gift'),
        backgroundColor: Colors.pinkAccent,
      ),
      body: FadeTransition(
        opacity: _fadeInAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Gift Name
                TextFormField(
                  key: const Key('gift_name_field'), // Added Key
                  controller: _nameController,
                  decoration: _inputDecoration('Gift Name'),
                  validator: (value) =>
                  value!.isEmpty ? 'Please enter a gift name' : null,
                ),
                const SizedBox(height: 16),
                // Description
                TextFormField(
                  key: const Key('gift_description_field'), // Added Key
                  controller: _descriptionController,
                  decoration: _inputDecoration('Description'),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                // Category
                TextFormField(
                  key: const Key('gift_category_field'), // Added Key
                  controller: _categoryController,
                  decoration: _inputDecoration('Category'),
                ),
                const SizedBox(height: 16),
                // Price
                TextFormField(
                  key: const Key('gift_price_field'), // Added Key
                  controller: _priceController,
                  decoration: _inputDecoration('Price'),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                  double.tryParse(value!) == null ? 'Enter a valid price' : null,
                ),
                const SizedBox(height: 16),
                // Status
                DropdownButtonFormField<String>(
                  value: _status,
                  items: const [
                    DropdownMenuItem(value: 'Available', child: Text('Available')),
                    DropdownMenuItem(value: 'Pledged', child: Text('Pledged')),
                  ],
                  onChanged: (value) => setState(() => _status = value!),
                  decoration: _inputDecoration('Status'),
                ),
                const SizedBox(height: 16),
                // Image Picker
                _buildImagePicker(),
                const SizedBox(height: 24),
                // Save Gift Button
                ElevatedButton.icon(
                  key: const Key('save_gift_button'), // Added Key
                  onPressed: _saveGift,
                  icon: const Icon(Icons.save),
                  label: const Text('Save Gift'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pinkAccent,
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: _pickImage,
          icon: const Icon(Icons.image),
          label: const Text('Upload Image'),
        ),
        if (_image != null) ...[
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              _image!,
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        ],
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
    _categoryController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
