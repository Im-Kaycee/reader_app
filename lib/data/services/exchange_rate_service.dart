import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ExchangeRate {
  final String currency;
  final String symbol;
  final double rateToNgn;

  const ExchangeRate({
    required this.currency,
    required this.symbol,
    required this.rateToNgn,
  });
}

class ExchangeRateService {
  static const _url = 'https://open.er-api.com/v6/latest/USD';

  Future<List<ExchangeRate>> fetchRates() async {
    try {
      final response = await http
          .get(Uri.parse(_url))
          .timeout(const Duration(seconds: 10));

      debugPrint('Status: ${response.statusCode}');

      if (response.statusCode != 200) return [];

      final data = jsonDecode(response.body);
      final rates = data['rates'] as Map<String, dynamic>;

      final usdToNgn = (rates['NGN'] as num).toDouble();
      final gbpToUsd = (rates['GBP'] as num).toDouble();
      final eurToUsd = (rates['EUR'] as num).toDouble();

      // Convert USD-based rates to NGN
      // 1 GBP = (1/GBP per USD) * USD→NGN
      final gbpToNgn = usdToNgn / gbpToUsd;
      final eurToNgn = usdToNgn / eurToUsd;

      debugPrint('USD→NGN: $usdToNgn');
      debugPrint('GBP→NGN: $gbpToNgn');
      debugPrint('EUR→NGN: $eurToNgn');

      return [
        ExchangeRate(currency: 'USD', symbol: '\$', rateToNgn: usdToNgn),
        ExchangeRate(currency: 'GBP', symbol: '£', rateToNgn: gbpToNgn),
        ExchangeRate(currency: 'EUR', symbol: '€', rateToNgn: eurToNgn),
      ];
    } catch (e, stack) {
      debugPrint('Exchange rate fetch failed: $e');
      debugPrint('Stack: $stack');
      return [];
    }
  }
}