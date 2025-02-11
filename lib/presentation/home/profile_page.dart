import 'package:flutter/material.dart';
import 'package:offnet/data/objectbox.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart'; // Add this dependency to pubspec.yaml

class ProfilePage extends StatefulWidget {
  final ObjectBox objectBox;

  const ProfilePage({Key? key, required this.objectBox}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late TextEditingController _nameController;
  bool _isEditing = false;
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    final selfUser = widget.objectBox.selfUserBox.getAll().first;
    _nameController = TextEditingController(text: selfUser.name);
    _imagePath = selfUser.pathToImage;
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _imagePath = image.path;
      });
    }
  }

  void _saveChanges() {
    final selfUser = widget.objectBox.selfUserBox.getAll().first;
    selfUser.name = _nameController.text;
    selfUser.pathToImage = _imagePath;
    widget.objectBox.selfUserBox.put(selfUser);
    setState(() {
      _isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final selfUser = widget.objectBox.selfUserBox.getAll().first;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: () {
              if (_isEditing) {
                _saveChanges();
              } else {
                setState(() {
                  _isEditing = true;
                });
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center, // Add this
          children: [
            Center(
              // This is already centered
              child: GestureDetector(
                // Moved GestureDetector inside Center
                onTap: _isEditing ? _pickImage : null,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: _imagePath != null
                          ? FileImage(File(_imagePath!))
                          : null,
                      child: _imagePath == null
                          ? Text(
                              selfUser.name[0].toUpperCase(),
                              style: const TextStyle(fontSize: 40),
                            )
                          : null,
                    ),
                    if (_isEditing)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (_isEditing)
              SizedBox(
                // Wrap TextField in SizedBox for width constraint
                width: 250, // Add reasonable max width
                child: TextField(
                  textAlign: TextAlign.center, // Center the text input
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                ),
              )
            else
              Center(
                // Center the name text
                child: Text(
                  selfUser.name,
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
              ),
            const SizedBox(height: 10),
            Center(
              // Center the ID text
              child: Text(
                'ID: ${selfUser.uniqueId}',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}
