import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import '../../controllers/notes_controller.dart';
import '../../data/models/note_model.dart';
import 'add_note_view.dart';
import 'image_viewer.dart';

class NoteDetailView extends StatelessWidget {
  final Note note;
  final int index;
  const NoteDetailView({Key? key, required this.note, required this.index})
    : super(key: key);
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<NotesController>();
    return Scaffold(
      appBar: AppBar(
        title: Text('Note Details'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed:
                () => Get.to(
                  () => AddNoteView(noteToEdit: note, noteIndex: index),
                ),
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              Get.defaultDialog(
                title: 'Delete Note',
                middleText: 'Are you sure you want to delete this note?',
                textConfirm: 'Delete',
                textCancel: 'Cancel',
                confirmTextColor: Colors.white,
                onConfirm: () {
                  controller.deleteNote(index);
                  Get.back();
                  Get.back();
                },
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              note.title,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Last updated: ${_formatDate(note.updatedAt)}',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            SizedBox(height: 16),
            if (note.images.isNotEmpty) ...[
              _buildImagesGrid(context),
              SizedBox(height: 16),
            ],
            if (note.content.isNotEmpty)
              Text(note.content, style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildImagesGrid(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: note.images.length,
      itemBuilder: (context, imageIndex) {
        return GestureDetector(
          onTap:
              () => Get.to(
                () => ImageViewer(
                  imagePaths: note.images.map((img) => img.path).toList(),
                  initialIndex: imageIndex,
                  noteId: note.id,
                ),
              ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              File(note.images[imageIndex].path),
              fit: BoxFit.cover,
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
