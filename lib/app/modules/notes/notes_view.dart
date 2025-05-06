import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import '../../controllers/notes_controller.dart';
import '../../data/models/note_model.dart';
import '../../routes/app_pages.dart';
import 'add_note_view.dart';
import 'note_detail_view.dart';

class NotesView extends GetView<NotesController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Notes'), centerTitle: true),
      body: Obx(() {
        if (controller.notes.isEmpty) {
          return Center(child: Text('No notes yet. Add your first note!'));
        }
        return GridView.builder(
          padding: EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.8,
          ),
          itemCount: controller.notes.length,
          itemBuilder: (context, index) {
            final note = controller.notes[index];
            return GestureDetector(
              onTap:
                  () => Get.to(() => NoteDetailView(note: note, index: index)),
              child: Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (note.images.isNotEmpty) _buildNoteImage(note),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            note.title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 8),
                          if (note.content.isNotEmpty)
                            Text(
                              note.content,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => Get.to(() => AddNoteView()),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3,
        onTap: (index) {
          switch (index) {
            case 0:
              Get.offAllNamed(Routes.HOME);
              break;
            case 1:
              Get.offAndToNamed(Routes.FAVORITES);
              break;
            case 2:
              Get.offAndToNamed(Routes.TODO);
              break;
            case 3:
              break;
          }
        },
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.check_box), label: 'To-Do'),
          BottomNavigationBarItem(icon: Icon(Icons.note), label: 'Notes'),
        ],
      ),
    );
  }

  Widget _buildNoteImage(Note note) {
    final imageCount = note.images.length;
    if (imageCount == 1) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: ClipRRect(
          borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
          child: Image.file(File(note.images[0].path), fit: BoxFit.cover),
        ),
      );
    } else if (imageCount == 2) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: Row(
          children: [
            Expanded(
              child: AspectRatio(
                aspectRatio: 8 / 9,
                child: Image.file(File(note.images[0].path), fit: BoxFit.cover),
              ),
            ),
            Expanded(
              child: AspectRatio(
                aspectRatio: 8 / 9,
                child: Image.file(File(note.images[1].path), fit: BoxFit.cover),
              ),
            ),
          ],
        ),
      );
    } else if (imageCount == 3) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: Row(
          children: [
            Expanded(
              child: AspectRatio(
                aspectRatio: 8 / 9,
                child: Image.file(File(note.images[0].path), fit: BoxFit.cover),
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: AspectRatio(
                      aspectRatio: 8 / 4.5,
                      child: Image.file(
                        File(note.images[1].path),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Expanded(
                    child: AspectRatio(
                      aspectRatio: 8 / 4.5,
                      child: Image.file(
                        File(note.images[2].path),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } else if (imageCount >= 4) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: GridView.count(
          crossAxisCount: 2,
          physics: NeverScrollableScrollPhysics(),
          children: List.generate(
            imageCount > 4 ? 4 : imageCount,
            (i) => Image.file(File(note.images[i].path), fit: BoxFit.cover),
          ),
        ),
      );
    }
    return SizedBox();
  }
}
