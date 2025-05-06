import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../data/models/note_model.dart';
import '../data/repositories/note_repository.dart';

class NotesController extends GetxController {
  final NoteRepository _noteRepository = NoteRepository();
  final RxList<Note> notes = <Note>[].obs;
  final ImagePicker _picker = ImagePicker();
  @override
  void onInit() {
    super.onInit();
    loadNotes();
  }

  Future<void> loadNotes() async {
    notes.value = await _noteRepository.getNotes();
    notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  Future<void> addNote(String title, String content, List<XFile> images) async {
    List<NoteImage> noteImages = [];
    if (images.isNotEmpty) {
      final appDir = await getApplicationDocumentsDirectory();
      for (var image in images) {
        final fileName = '${Uuid().v4()}.jpg';
        final savedImage = await File(
          image.path,
        ).copy('${appDir.path}/$fileName');
        noteImages.add(NoteImage(id: Uuid().v4(), path: savedImage.path));
      }
    }
    final note = Note(
      id: Uuid().v4(),
      title: title,
      content: content,
      images: noteImages,
    );
    await _noteRepository.addNote(note);
    await loadNotes();
  }

  Future<void> updateNote(int index, Note note, List<XFile> newImages) async {
    List<NoteImage> noteImages = List.from(note.images);
    if (newImages.isNotEmpty) {
      final appDir = await getApplicationDocumentsDirectory();
      for (var image in newImages) {
        final fileName = '${Uuid().v4()}.jpg';
        final savedImage = await File(
          image.path,
        ).copy('${appDir.path}/$fileName');
        noteImages.add(NoteImage(id: Uuid().v4(), path: savedImage.path));
      }
    }
    note.images = noteImages;
    note.updatedAt = DateTime.now();
    await _noteRepository.updateNote(index, note);
    await loadNotes();
  }

  Future<void> deleteNote(int index) async {
    final note = notes[index];
    for (var image in note.images) {
      final file = File(image.path);
      if (await file.exists()) {
        await file.delete();
      }
    }
    await _noteRepository.deleteNote(index);
    await loadNotes();
  }

  Future<void> removeImage(int noteIndex, int imageIndex) async {
    final note = notes[noteIndex];
    final image = note.images[imageIndex];
    final file = File(image.path);
    if (await file.exists()) {
      await file.delete();
    }
    note.images.removeAt(imageIndex);
    note.updatedAt = DateTime.now();
    await _noteRepository.updateNote(noteIndex, note);
    await loadNotes();
  }

  Future<List<XFile>> pickImages() async {
    final List<XFile> images = await _picker.pickMultiImage();
    return images;
  }

  Future<XFile?> pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    return image;
  }
}
