import 'package:flutter/material.dart';
import 'package:candlesticks/candlesticks.dart';
import '../services/binance_service.dart';
import 'dart:math';

class MarketAnalysisScreen extends StatefulWidget {
  const MarketAnalysisScreen({Key? key}) : super(key: key);

  @override
  State<MarketAnalysisScreen> createState() => _MarketAnalysisScreenState();
}

class _MarketAnalysisScreenState extends State<MarketAnalysisScreen> {
  List<Candle>? _candles;
  bool _loading = true;
  String? _error;

  String _selectedSymbol = 'BTCUSDT';
  String _selectedInterval = '1h';
  List<String> _allSymbols = [];
  bool _symbolsLoading = true;

  final List<String> _intervals = ['1m', '5m', '15m', '1h', '4h', '1d'];

  double? _rsi;
  double? _macd;
  double? _volume;
  List<String> _alerts = [];
  Candle? _selectedCandle;

  Candle? get _lastCandle =>
      _candles != null && _candles!.isNotEmpty ? _candles!.last : null;

  @override
  void initState() {
    super.initState();
    _fetchSymbols();
    _loadCandles();
  }

  Future<void> _fetchSymbols() async {
    setState(() {
      _symbolsLoading = true;
    });
    try {
      final symbols = await BinanceService.fetchAllSymbols();
      setState(() {
        _allSymbols = symbols;
        _symbolsLoading = false;
      });
    } catch (e) {
      setState(() {
        _allSymbols = ['BTCUSDT', 'ETHUSDT', 'BNBUSDT', 'SOLUSDT'];
        _symbolsLoading = false;
      });
    }
  }

  Future<void> _loadCandles() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final candles = await BinanceService.fetchCandles(
        symbol: _selectedSymbol,
        interval: _selectedInterval,
        limit: 50,
      );
      setState(() {
        _candles = candles;
        _loading = false;
        _calculateIndicators();
        _detectAlerts();
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _onSymbolChanged(String value) {
    if (value.isNotEmpty && value != _selectedSymbol) {
      setState(() {
        _selectedSymbol = value;
      });
      _loadCandles();
    }
  }

  void _onIntervalChanged(String? value) {
    if (value != null && value != _selectedInterval) {
      setState(() {
        _selectedInterval = value;
      });
      _loadCandles();
    }
  }

  void _calculateIndicators() {
    if (_candles == null || _candles!.length < 26) {
      _rsi = null;
      _macd = null;
      _volume = null;
      return;
    }
    final closes = _candles!.map((c) => c.close).toList();
    final volumes = _candles!.map((c) => c.volume).toList();
    _rsi = _calculateRSI(closes, 14);
    _macd = _calculateMACD(closes);
    _volume = volumes.last;
  }

  double? _calculateRSI(List<double> closes, int period) {
    if (closes.length < period + 1) return null;
    double gain = 0, loss = 0;
    for (int i = closes.length - period; i < closes.length; i++) {
      final diff = closes[i] - closes[i - 1];
      if (diff >= 0) {
        gain += diff;
      } else {
        loss -= diff;
      }
    }
    if (gain + loss == 0) return 50;
    final rs = gain / (loss == 0 ? 1 : loss);
    return 100 - (100 / (1 + rs));
  }

  double? _calculateMACD(List<double> closes) {
    if (closes.length < 26) return null;
    double ema(List<double> values, int period) {
      double k = 2 / (period + 1);
      double ema = values[0];
      for (int i = 1; i < values.length; i++) {
        ema = values[i] * k + ema * (1 - k);
      }
      return ema;
    }

    final ema12 = ema(closes.sublist(closes.length - 12), 12);
    final ema26 = ema(closes.sublist(closes.length - 26), 26);
    return ema12 - ema26;
  }

  void _detectAlerts() {
    _alerts = [];
    if (_candles == null || _candles!.isEmpty) return;
    final last = _candles!.last;
    final closes = _candles!.map((c) => c.close).toList();
    final volumes = _candles!.map((c) => c.volume).toList();
    // Volumen inusualmente alto
    final avgVolume = volumes.length > 1
        ? volumes.sublist(0, volumes.length - 1).reduce((a, b) => a + b) /
              (volumes.length - 1)
        : 0;
    if (last.volume > avgVolume * 1.8) {
      _alerts.add('Volumen inusualmente alto: ${_formatVolume(last.volume)}');
    }
    // RSI sobrecompra/sobreventa
    if (_rsi != null) {
      if (_rsi! > 70) {
        _alerts.add('RSI en sobrecompra (${_rsi!.toStringAsFixed(2)})');
      } else if (_rsi! < 30) {
        _alerts.add('RSI en sobreventa (${_rsi!.toStringAsFixed(2)})');
      }
    }
    // Patrón de vela martillo (hammer)
    if (_isHammer(last)) {
      _alerts.add('Posible patrón de martillo detectado');
    }
  }

  bool _isHammer(Candle c) {
    final body = (c.open - c.close).abs();
    final lowerWick = c.close < c.open ? c.low - c.close : c.low - c.open;
    final upperWick = c.close > c.open ? c.high - c.close : c.high - c.open;
    return body < (upperWick + lowerWick) * 0.3 &&
        lowerWick > body * 2 &&
        upperWick < body * 0.5;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Análisis de Mercado')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: _symbolsLoading
                      ? const Center(child: CircularProgressIndicator())
                      : Autocomplete<String>(
                          optionsBuilder: (TextEditingValue textEditingValue) {
                            if (textEditingValue.text == '') {
                              return _allSymbols;
                            }
                            return _allSymbols.where(
                              (String option) => option.toLowerCase().contains(
                                textEditingValue.text.toLowerCase(),
                              ),
                            );
                          },
                          initialValue: TextEditingValue(text: _selectedSymbol),
                          onSelected: _onSymbolChanged,
                          fieldViewBuilder:
                              (
                                context,
                                controller,
                                focusNode,
                                onFieldSubmitted,
                              ) {
                                controller.text = _selectedSymbol;
                                return TextField(
                                  controller: controller,
                                  focusNode: focusNode,
                                  decoration: const InputDecoration(
                                    labelText: 'Par',
                                    border: OutlineInputBorder(),
                                  ),
                                  onSubmitted: (value) =>
                                      _onSymbolChanged(value),
                                );
                              },
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedInterval,
                    items: _intervals
                        .map((i) => DropdownMenuItem(value: i, child: Text(i)))
                        .toList(),
                    onChanged: _onIntervalChanged,
                    decoration: const InputDecoration(
                      labelText: 'Intervalo',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              height: 260,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(
                children: [
                  if (_loading)
                    const Center(child: CircularProgressIndicator())
                  else if (_error != null)
                    Center(child: Text('Error: $_error'))
                  else if (_candles == null || _candles!.isEmpty)
                    const Center(child: Text('Sin datos'))
                  else
                    Candlesticks(candles: _candles!),
                  // Panel de detalles de la última vela
                  if (_lastCandle != null)
                    Positioned(
                      top: 8,
                      left: 8,
                      right: 8,
                      child: Card(
                        color: Theme.of(
                          context,
                        ).colorScheme.background.withOpacity(0.95),
                        elevation: 4,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${_lastCandle!.date.year}-${_lastCandle!.date.month.toString().padLeft(2, '0')}-${_lastCandle!.date.day.toString().padLeft(2, '0')} ${_lastCandle!.date.hour.toString().padLeft(2, '0')}:${_lastCandle!.date.minute.toString().padLeft(2, '0')}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'O: ${_lastCandle!.open.toStringAsFixed(2)}',
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'H: ${_lastCandle!.high.toStringAsFixed(2)}',
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'L: ${_lastCandle!.low.toStringAsFixed(2)}',
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'C: ${_lastCandle!.close.toStringAsFixed(2)}',
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'V: ${_formatVolume(_lastCandle!.volume)}',
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Indicadores técnicos
            Text(
              'Indicadores Técnicos',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _IndicatorChip(
                    label: 'RSI',
                    value: _rsi != null ? _rsi!.toStringAsFixed(2) : '--',
                  ),
                  const SizedBox(width: 8),
                  _IndicatorChip(
                    label: 'MACD',
                    value: _macd != null ? _macd!.toStringAsFixed(2) : '--',
                  ),
                  const SizedBox(width: 8),
                  _IndicatorChip(
                    label: 'Volumen',
                    value: _volume != null ? _formatVolume(_volume!) : '--',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Alertas Inteligentes',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            if (_alerts.isEmpty)
              const Card(
                color: Color(0xFFE0E0E0),
                child: ListTile(
                  leading: Icon(Icons.check_circle, color: Colors.green),
                  title: Text('Sin alertas detectadas'),
                ),
              )
            else
              ..._alerts.map(
                (alert) => Card(
                  color: alert.contains('Volumen')
                      ? Colors.green.shade100
                      : alert.contains('sobrecompra') ||
                            alert.contains('sobreventa')
                      ? Colors.orange.shade100
                      : Colors.blue.shade100,
                  child: ListTile(
                    leading: Icon(
                      alert.contains('Volumen')
                          ? Icons.trending_up
                          : alert.contains('sobrecompra') ||
                                alert.contains('sobreventa')
                          ? Icons.warning
                          : Icons.candlestick_chart,
                      color: alert.contains('Volumen')
                          ? Colors.green
                          : alert.contains('sobrecompra') ||
                                alert.contains('sobreventa')
                          ? Colors.orange
                          : Colors.blue,
                    ),
                    title: Text(alert),
                    subtitle: Text('$_selectedSymbol - $_selectedInterval'),
                    trailing: const Icon(Icons.chevron_right),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatVolume(double v) {
    if (v >= 1e9) return (v / 1e9).toStringAsFixed(2) + 'B';
    if (v >= 1e6) return (v / 1e6).toStringAsFixed(2) + 'M';
    if (v >= 1e3) return (v / 1e3).toStringAsFixed(2) + 'K';
    return v.toStringAsFixed(2);
  }
}

class _IndicatorChip extends StatelessWidget {
  final String label;
  final String value;
  const _IndicatorChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text('$label: $value'),
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
    );
  }
}
