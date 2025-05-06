import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/quote_model.dart';

class QuotesProvider {
  static const String _typeFitApiUrl = 'https://type.fit/api/quotes';
  static const String _zenQuotesApiUrl = 'https://zenquotes.io/api/quotes';
  Future<List<Quote>> getQuotes() async {
    try {
      final zenResponse = await http.get(Uri.parse(_zenQuotesApiUrl));
      if (zenResponse.statusCode == 200) {
        final List<dynamic> data = json.decode(zenResponse.body);
        return data
            .map(
              (json) =>
                  Quote(text: json['q'] ?? '', author: json['a'] ?? 'Unknown'),
            )
            .toList();
      }
      final response = await http.get(Uri.parse(_typeFitApiUrl));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Quote.fromJson(json)).toList();
      }
    } catch (e) {
      print('Error fetching quotes: $e');
    }
    return [
      Quote(
        text: 'The best way to predict the future is to create it.',
        author: 'Abraham Lincoln',
      ),
    ];
  }
}
