import 'dart:convert';
import 'package:current_currency_app/constants/app_string.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:current_currency_app/models/conversion_history.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';

class CurrencyProvider with ChangeNotifier {
  final List<String> _currencies = ['USD', 'INR', 'EUR', 'GBP', 'AUD'];
  List<String> get currencies => _currencies;

  String _fromCurrency = 'USD';
  String get fromCurrency => _fromCurrency;

  String _toCurrency = 'INR';
  String get toCurrency => _toCurrency;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _result = "";
  String get result => _result;

  List<ConversionHistory> _history = [];
  List<ConversionHistory> get history => _history;

  Map<String, dynamic> exchangeRates = {};

  CurrencyProvider() {
    loadData();
  }

  void setFromCurrencyValue(String value) {
    _fromCurrency = value;
    notifyListeners();
  }

  void setToCurrencyValue(String value) {
    _toCurrency = value;
    notifyListeners();
  }

  /// Converts the given amount from one currency to another
  Future<void> convertCurrency(String amountText) async {
    if (amountText.isEmpty) {
      _result = AppStrings.pleaseEnterAmount;
      notifyListeners();
      return;
    }

    final double? amount = double.tryParse(amountText);
    if (amount == null) {
      _result = AppStrings.invalidAmount;
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    if (exchangeRates.isEmpty) {
      await loadData();
    }

    num fromRate = exchangeRates[fromCurrency] ?? 1.0;
    num toRate = exchangeRates[toCurrency] ?? 1.0;

    double convertedAmount = (toRate / fromRate) * amount;
    _result = convertedAmount.toStringAsFixed(2);

    ConversionHistory newEntry = ConversionHistory(
      amount: amount,
      fromCurrency: _fromCurrency,
      toCurrency: _toCurrency,
      convertedAmount: convertedAmount,
    );
    _history.insert(0, newEntry);

    await saveHistory();

    _isLoading = false;
    notifyListeners();
  }

  /// Saves the history list to shared preferences
  Future<void> saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyList = _history.map((e) => e.toMap()).toList();
    await prefs.setString('history', jsonEncode(historyList));
  }

  /// Loads the exchange rates and conversion history
  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final historyData = prefs.getString('history');
    final rateData = prefs.getString('rates');

    if (historyData != null) {
      final List<dynamic> historyList = jsonDecode(historyData);
      _history = historyList.map((e) => ConversionHistory.fromMap(e)).toList();
    }

    final connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      await fetchExchangeRates();
    } else {
      if (rateData != null) {
        exchangeRates = jsonDecode(rateData);
      } else {
        debugPrint(AppStrings.noInternetNoData);
      }
    }
    notifyListeners();
  }

  /// Fetches the latest exchange rates from API
  Future<void> fetchExchangeRates() async {
    try {
      final url = Uri.parse(
        "https://api.exchangerate-api.com/v4/latest/$_fromCurrency",
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        exchangeRates = data['rates'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('rates', jsonEncode(exchangeRates));
      } else {
        debugPrint('${AppStrings.apiError} ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error: ${e.toString()}');
    }
  }
}
