import 'package:hive/hive.dart';
part 'note_model.g.dart';

@HiveType(typeId: 3)
class Note {
  @HiveField(0)
  final String id;
  @HiveField(1)
  String title;
  @HiveField(2)
  String content;
  @HiveField(3)
  List<NoteImage> images;
  @HiveField(4)
  DateTime createdAt;
  @HiveField(5)
  DateTime updatedAt;
  Note({
    required this.id,
    required this.title,
    this.content = '',
    List<NoteImage>? images,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : this.images = images ?? [],
       this.createdAt = createdAt ?? DateTime.now(),
       this.updatedAt = updatedAt ?? DateTime.now();
}

@HiveType(typeId: 4)
class NoteImage {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String path;
  NoteImage({required this.id, required this.path});
}
