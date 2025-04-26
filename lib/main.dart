//in this file we call the main page ie .Currency home page

import 'package:current_currency_app/constants/app_string.dart';
import 'package:current_currency_app/providers/currency_provider.dart';
import 'package:current_currency_app/providers/theme_provider.dart';
import 'package:current_currency_app/screens/currency_home_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => CurrencyProvider()),
      ],

      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    dynamic themeprovider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppStrings.currencyConverterText,
      themeMode: themeprovider.themeMode,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: CurrencyHomePage(),
    );
  }
}
