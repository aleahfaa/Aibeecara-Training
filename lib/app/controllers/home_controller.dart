import 'package:get/get.dart';
import '../data/models/quote_model.dart';
import '../data/models/todo_model.dart';
import '../data/repositories/quotes_repository.dart';
import '../data/repositories/todo_repository.dart';
import '../controllers/favorites_controller.dart';

class HomeController extends GetxController {
  final QuotesRepository _quotesRepository = QuotesRepository();
  final TodoRepository _todoRepository = TodoRepository();
  final Rx<Quote?> currentQuote = Rx<Quote?>(null);
  final RxBool isLoading = true.obs;
  final RxList<Todo> upcomingTasks = <Todo>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchQuote();
    loadUpcomingTasks();
  }

  Future<void> fetchQuote() async {
    isLoading.value = true;
    try {
      final quotes = await _quotesRepository.getQuotes();
      if (quotes.isNotEmpty) {
        quotes.shuffle();
        currentQuote.value = quotes.first;
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadUpcomingTasks() async {
    try {
      final allTasks = await _todoRepository.getTodos();
      final incompleteTasks =
          allTasks.where((task) => !task.isCompleted).toList();
      incompleteTasks.sort((a, b) {
        if (a.dueDate == null && b.dueDate == null) return 0;
        if (a.dueDate == null) return 1;
        if (b.dueDate == null) return -1;
        int dateComparison = a.dueDate!.compareTo(b.dueDate!);
        if (dateComparison != 0) return dateComparison;
        if (a.dueTime == null && b.dueTime == null) return 0;
        if (a.dueTime == null) return 1;
        if (b.dueTime == null) return -1;
        return a.dueTime!.compareTo(b.dueTime!);
      });
      upcomingTasks.value = incompleteTasks.take(3).toList();
    } catch (e) {
      print('Error loading upcoming tasks: $e');
      upcomingTasks.value = [];
    }
  }

  bool isFavorite() {
    if (currentQuote.value == null) return false;
    return _quotesRepository.isFavorite(currentQuote.value!);
  }

  Future<void> toggleFavorite() async {
    if (currentQuote.value == null) return;
    if (isFavorite()) {
      final favorites = _quotesRepository.getFavorites();
      final index = favorites.indexWhere(
        (q) =>
            q.text == currentQuote.value!.text &&
            q.author == currentQuote.value!.author,
      );
      if (index >= 0) {
        await _quotesRepository.removeFromFavorites(index);
        if (Get.isRegistered<FavoritesController>()) {
          final favoritesController = Get.find<FavoritesController>();
          favoritesController.loadFavorites();
        }
      }
    } else {
      await _quotesRepository.addToFavorites(currentQuote.value!);
      if (Get.isRegistered<FavoritesController>()) {
        final favoritesController = Get.find<FavoritesController>();
        favoritesController.loadFavorites();
      }
    }
    update();
  }

  void refreshTasks() {
    loadUpcomingTasks();
  }
}
