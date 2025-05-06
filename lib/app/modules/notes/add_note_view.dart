import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../controllers/notes_controller.dart';
import '../../data/models/note_model.dart';

class AddNoteView extends StatefulWidget {
  final Note? noteToEdit;
  final int? noteIndex;
  const AddNoteView({Key? key, this.noteToEdit, this.noteIndex})
    : super(key: key);
  @override
  _AddNoteViewState createState() => _AddNoteViewState();
}

class _AddNoteViewState extends State<AddNoteView> {
  final NotesController controller = Get.find<NotesController>();
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  List<XFile> _newImages = [];
  List<NoteImage> _existingImages = [];
  @override
  void initState() {
    super.initState();
    if (widget.noteToEdit != null) {
      _titleController.text = widget.noteToEdit!.title;
      _contentController.text = widget.noteToEdit!.content;
      _existingImages = List.from(widget.noteToEdit!.images);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final images = await controller.pickImages();
    if (images.isNotEmpty) {
      setState(() {
        _newImages.addAll(images);
      });
    }
  }

  void _removeNewImage(int index) {
    setState(() {
      _newImages.removeAt(index);
    });
  }

  void _removeExistingImage(int index) {
    setState(() {
      _existingImages.removeAt(index);
    });
  }

  void _saveNote() {
    if (_formKey.currentState!.validate()) {
      if (widget.noteToEdit != null && widget.noteIndex != null) {
        widget.noteToEdit!.title = _titleController.text.trim();
        widget.noteToEdit!.content = _contentController.text.trim();
        widget.noteToEdit!.images = _existingImages;
        widget.noteToEdit!.updatedAt = DateTime.now();
        controller.updateNote(
          widget.noteIndex!,
          widget.noteToEdit!,
          _newImages,
        );
      } else {
        controller.addNote(
          _titleController.text.trim(),
          _contentController.text.trim(),
          _newImages,
        );
      }
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.noteToEdit != null ? 'Edit Note' : 'Add Note'),
        centerTitle: true,
        actions: [IconButton(icon: Icon(Icons.save), onPressed: _saveNote)],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _contentController,
                decoration: InputDecoration(
                  labelText: 'Content',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 8,
              ),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Images',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: Icon(Icons.add_photo_alternate),
                    onPressed: _pickImages,
                    tooltip: 'Add Images',
                  ),
                ],
              ),
              SizedBox(height: 8),
              if (_existingImages.isNotEmpty) ...[
                Text(
                  'Existing Images',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 8),
                GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: _existingImages.length,
                  itemBuilder: (context, index) {
                    return Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(_existingImages[index].path),
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () => _removeExistingImage(index),
                            child: Container(
                              padding: EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                SizedBox(height: 16),
              ],
              if (_newImages.isNotEmpty) ...[
                Text(
                  'New Images',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 8),
                GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: _newImages.length,
                  itemBuilder: (context, index) {
                    return Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(_newImages[index].path),
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () => _removeNewImage(index),
                            child: Container(
                              padding: EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
              if (_existingImages.isEmpty && _newImages.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Text(
                      'No images added',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
              SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      widget.noteToEdit != null ? 'Update Note' : 'Save Note',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  onPressed: _saveNote,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
