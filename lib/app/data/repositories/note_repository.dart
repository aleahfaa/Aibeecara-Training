import '../models/note_model.dart';
import 'package:hive/hive.dart';

class NoteRepository {
  Future<List<Note>> getNotes() async {
    final box = Hive.box<Note>('notes');
    return box.values.toList();
  }

  Future<void> addNote(Note note) async {
    final box = Hive.box<Note>('notes');
    await box.add(note);
  }

  Future<void> updateNote(int index, Note note) async {
    final box = Hive.box<Note>('notes');
    await box.putAt(index, note);
  }

  Future<void> deleteNote(int index) async {
    final box = Hive.box<Note>('notes');
    await box.deleteAt(index);
  }
}
