import 'package:current_currency_app/constants/app_string.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:current_currency_app/providers/currency_provider.dart';
import 'package:current_currency_app/providers/theme_provider.dart';

class CurrencyHomePage extends StatefulWidget {
  const CurrencyHomePage({super.key});

  @override
  State<CurrencyHomePage> createState() => _CurrencyHomePageState();
}

class _CurrencyHomePageState extends State<CurrencyHomePage> {
  final TextEditingController _amountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final currencyProvider = context.watch<CurrencyProvider>();
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      backgroundColor:
          themeProvider.themeMode != ThemeMode.dark
              ? Colors.white
              : Colors.black,
      appBar: AppBar(
        backgroundColor:
            themeProvider.themeMode != ThemeMode.dark
                ? Colors.white
                : Colors.black,
        title: const Text(
          AppStrings.currencyConverterText,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          // Theme toggle switch
          Switch(
            value: themeProvider.themeMode == ThemeMode.dark,
            onChanged: (value) => themeProvider.toggleTheme(value),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // From currency dropdown
            _buildDropdown(currencyProvider, isFrom: true),
            const SizedBox(height: 24),

            // To currency dropdown
            _buildDropdown(currencyProvider, isFrom: false),
            const SizedBox(height: 24),

            // Amount input field
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: AppStrings.amountLabelText,

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Convert button
            SizedBox(
              height: 50,
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      themeProvider.themeMode == ThemeMode.dark
                          ? Colors.white
                          : const Color.fromARGB(255, 215, 188, 220),
                ),
                onPressed: () {
                  currencyProvider.convertCurrency(_amountController.text);
                },
                child: const Text(
                  AppStrings.convertButtonText,
                  style: TextStyle(fontSize: 24),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Result display or loading indicator
            currencyProvider.isLoading
                ? const CircularProgressIndicator()
                : Text(
                  "Result   ${currencyProvider.result}",
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            const SizedBox(height: 34),

            // Conversion history
            const Divider(),
            const Text(
              AppStrings.conversionHistoryText,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            Consumer<CurrencyProvider>(
              builder: (context, currencyProvider, child) {
                if (currencyProvider.history.isEmpty) {
                  return const Center(child: Text(AppStrings.noHistoryText));
                } else {
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: currencyProvider.history.length,
                    itemBuilder: (context, index) {
                      final item = currencyProvider.history[index];
                      return ListTile(
                        leading: const Icon(Icons.history),
                        title: Text(
                          "${item.amount} ${item.fromCurrency} -> "
                          "${item.convertedAmount.toStringAsFixed(2)} ${item.toCurrency}",
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Dropdown widget for currency selection
Widget _buildDropdown(CurrencyProvider provider, {required bool isFrom}) {
  return DropdownButtonFormField<String>(
    value: isFrom ? provider.fromCurrency : provider.toCurrency,
    items:
        provider.currencies.map((currency) {
          return DropdownMenuItem(value: currency, child: Text(currency));
        }).toList(),
    onChanged: (value) {
      if (value != null) {
        isFrom
            ? provider.setFromCurrencyValue(value)
            : provider.setToCurrencyValue(value);
      }
    },
    decoration: InputDecoration(
      labelText:
          isFrom ? AppStrings.fromCurrencyLabel : AppStrings.toCurrencyLabel,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
    ),
  );
}
