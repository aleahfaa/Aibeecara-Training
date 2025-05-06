import '../models/quote_model.dart';
import '../providers/quotes_provider.dart';
import 'package:hive/hive.dart';

class QuotesRepository {
  final QuotesProvider _quotesProvider = QuotesProvider();
  Future<List<Quote>> getQuotes() async {
    return await _quotesProvider.getQuotes();
  }

  List<Quote> getFavorites() {
    final box = Hive.box<Quote>('favorites');
    return box.values.toList();
  }

  Future<void> addToFavorites(Quote quote) async {
    final box = Hive.box<Quote>('favorites');
    await box.add(quote);
  }

  Future<void> removeFromFavorites(int index) async {
    final box = Hive.box<Quote>('favorites');
    await box.deleteAt(index);
  }

  bool isFavorite(Quote quote) {
    final box = Hive.box<Quote>('favorites');
    return box.values.any(
      (q) => q.text == quote.text && q.author == quote.author,
    );
  }
}
