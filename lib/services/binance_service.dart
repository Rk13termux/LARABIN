import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:candlesticks/candlesticks.dart';

class BinanceService {
  static const String _baseUrl = 'https://api.binance.com/api/v3/klines';
  static const String _exchangeInfoUrl =
      'https://api.binance.com/api/v3/exchangeInfo';

  /// Obtiene velas de cualquier par y timeframe soportado por Binance
  static Future<List<Candle>> fetchCandles({
    required String symbol,
    required String interval,
    int limit = 50,
  }) async {
    final uri = Uri.parse(
      '$_baseUrl?symbol=$symbol&interval=$interval&limit=$limit',
    );
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data
          .map(
            (e) => Candle(
              date: DateTime.fromMillisecondsSinceEpoch(e[0]),
              open: double.parse(e[1]),
              high: double.parse(e[2]),
              low: double.parse(e[3]),
              close: double.parse(e[4]),
              volume: double.parse(e[5]),
            ),
          )
          .toList();
    } else {
      throw Exception(
        'Error al obtener datos de Binance: ${response.statusCode}',
      );
    }
  }

  /// Obtiene todos los pares de trading disponibles en Binance
  static Future<List<String>> fetchAllSymbols() async {
    final uri = Uri.parse(_exchangeInfoUrl);
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List symbols = data['symbols'];
      return symbols
          .where((s) => s['status'] == 'TRADING')
          .map<String>((s) => s['symbol'] as String)
          .toList();
    } else {
      throw Exception(
        'Error al obtener símbolos de Binance: ${response.statusCode}',
      );
    }
  }
}
