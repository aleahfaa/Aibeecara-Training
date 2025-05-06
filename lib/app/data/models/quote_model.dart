import 'package:hive/hive.dart';
part 'quote_model.g.dart';

@HiveType(typeId: 0)
class Quote {
  @HiveField(0)
  final String text;
  @HiveField(1)
  final String author;
  Quote({required this.text, required this.author});
  factory Quote.fromJson(Map<String, dynamic> json) {
    return Quote(text: json['text'] ?? '', author: json['author'] ?? 'Unknown');
  }
  Map<String, dynamic> toJson() {
    return {'text': text, 'author': author};
  }
}
