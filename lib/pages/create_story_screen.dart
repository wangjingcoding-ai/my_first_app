import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:alterego/services/story_service.dart';

class CreateStoryScreen extends StatefulWidget {
  const CreateStoryScreen({super.key});

  @override
  State<CreateStoryScreen> createState() => _CreateStoryScreenState();
}

class _CreateStoryScreenState extends State<CreateStoryScreen> {
  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _summaryCtrl = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final StoryService _service = StoryService();
  File? _imageFile;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final xfile = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (xfile != null) {
      setState(() => _imageFile = File(xfile.path));
    }
  }

  Future<void> _startAdventure() async {
    final title = _titleCtrl.text.trim();
    final summary = _summaryCtrl.text.trim();
    if (title.isEmpty || summary.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter title and summary')));
      return;
    }
    setState(() => _isLoading = true);
    try {
      String? url;
      if (_imageFile != null) {
        url = await _service.uploadCover(_imageFile!);
      }
      await _service.createSession(title, summary, url);
      if (!mounted) return;
      Navigator.pushNamed(context, '/chat');
    } on DuplicateTitleException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('⚠️ This story name is already taken. Please choose another one!')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const neon = Color(0xFF00F5FF);
    final light = Theme.of(context).brightness == Brightness.light;
    return Scaffold(
      appBar: AppBar(title: const Text('Create Story')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GestureDetector(
            onTap: _isLoading ? null : _pickImage,
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                color: (light ? Colors.black : Colors.white).withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: neon.withValues(alpha: 0.35)),
              ),
              child: _imageFile != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.file(_imageFile!, fit: BoxFit.cover, width: double.infinity),
                    )
                  : Center(
                      child: Icon(Icons.add_photo_alternate_outlined, size: 48, color: neon.withValues(alpha: 0.8)),
                    ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _titleCtrl,
            decoration: const InputDecoration(labelText: 'Title', hintText: 'Enter story title'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _summaryCtrl,
            decoration: const InputDecoration(labelText: 'Summary', hintText: 'Describe your premise'),
            maxLines: 5,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _isLoading ? null : _startAdventure,
              child: _isLoading ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Start Adventure'),
            ),
          ),
        ],
      ),
    );
  }
}