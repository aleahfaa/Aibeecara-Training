import 'package:get/get.dart';
import '../bindings/splash_binding.dart';
import '../modules/splash/splash_view.dart';
import '../bindings/home_binding.dart';
import '../modules/home/home_view.dart';
import '../bindings/favorites_binding.dart';
import '../modules/favorites/favorites_view.dart';
import '../bindings/todo_binding.dart';
import '../modules/todo/todo_view.dart';
import '../bindings/notes_binding.dart';
import '../modules/notes/notes_view.dart';
part 'app_routes.dart';

class AppPages {
  static const INITIAL = Routes.SPLASH;
  static final routes = [
    GetPage(
      name: Routes.SPLASH,
      page: () => SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(name: Routes.HOME, page: () => HomeView(), binding: HomeBinding()),
    GetPage(
      name: Routes.FAVORITES,
      page: () => FavoritesView(),
      binding: FavoritesBinding(),
    ),
    GetPage(name: Routes.TODO, page: () => TodoView(), binding: TodoBinding()),
    GetPage(
      name: Routes.NOTES,
      page: () => NotesView(),
      binding: NotesBinding(),
    ),
  ];
}
