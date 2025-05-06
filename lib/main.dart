import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app/routes/app_pages.dart';
import 'app/data/models/quote_model.dart';
import 'app/data/models/todo_model.dart';
import 'app/data/models/note_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(QuoteAdapter());
  Hive.registerAdapter(TodoAdapter());
  Hive.registerAdapter(SubTaskAdapter());
  Hive.registerAdapter(NoteAdapter());
  Hive.registerAdapter(NoteImageAdapter());
  await Hive.openBox<Quote>('favorites');
  await Hive.openBox<Todo>('todos');
  await Hive.openBox<Note>('notes');
  runApp(
    GetMaterialApp(
      title: 'ENS',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      debugShowCheckedModeBanner: false,
    ),
  );
}
