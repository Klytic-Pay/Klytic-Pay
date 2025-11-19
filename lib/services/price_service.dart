import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';

class PriceService {
  Future<double> fetchBdagToUsdPrice() async {
    final url = Uri.parse(
        '${AppConstants.coingeckoApiBaseUrl}/simple/price?ids=${AppConstants.coingeckoBlockdagId}&vs_currencies=usd');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final price = json[AppConstants.coingeckoBlockdagId]?['usd'];
        if (price != null) {
          return price.toDouble();
        } else {
          throw Exception('BDAG price not found in CoinGecko response');
        }
      } else {
        throw Exception(
            'Failed to load BDAG price: Status code ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching BDAG price: $e');
    }
  }
}