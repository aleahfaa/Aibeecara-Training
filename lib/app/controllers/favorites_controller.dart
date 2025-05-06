import 'package:get/get.dart';
import '../data/models/quote_model.dart';
import '../data/repositories/quotes_repository.dart';
import '../controllers/home_controller.dart';

class FavoritesController extends GetxController {
  final QuotesRepository _quotesRepository = QuotesRepository();

  final RxList<Quote> favorites = <Quote>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadFavorites();
  }

  void loadFavorites() {
    favorites.value = _quotesRepository.getFavorites();
  }

  Future<void> removeFromFavorites(int index) async {
    final removedQuote = favorites[index];
    await _quotesRepository.removeFromFavorites(index);
    loadFavorites();
    if (Get.isRegistered<HomeController>()) {
      final homeController = Get.find<HomeController>();
      if (homeController.currentQuote.value != null &&
          homeController.currentQuote.value!.text == removedQuote.text &&
          homeController.currentQuote.value!.author == removedQuote.author) {
        homeController.update();
      }
    }
  }
}
