import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'widgets/ticker_app_shell.dart';
import 'store/store.dart';
import 'store/app_stores.dart';

void main() => runApp(new TickerApp());

// Define the app stores.
final Map<Type, Store> appStores = {
  SearchableSymbolsStore: SearchableSymbolsStore(),
  UserSymbolsStore: UserSymbolsStore()
};

class TickerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    // Provide the app stores to the descendant widgets.
    return StoreProvider(
      stores: appStores,
      child: MaterialApp(
        title: 'Ticker app',
        home: TickerAppShell(title: 'Ticker app'),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
