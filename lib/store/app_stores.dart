import 'dart:convert';

import 'package:http/http.dart' as http;

import 'store.dart';
import 'models.dart';

class SearchableSymbolsStore extends Store {
  SearchableSymbolsStore()
      : symbols = [],
        super() {
    _fetchSymbols();
  }

  List<SearchableSymbol> symbols;

  static const String kSearchableSymbolsEndpoint =
      'https://iextrading.com/api/1.0/ref-data/symbols';

  _fetchSymbols() async {
    final response = await http.get(kSearchableSymbolsEndpoint);
    if (response.statusCode == 200) {
      List<dynamic> result = json.decode(response.body);

      updateModel(() {
        symbols = result
            .map((item) => SearchableSymbol(
                  symbol: item['symbol'],
                  companyName: item['name'],
                ))
            .toList();
      });
    }
  }
}

class UserSymbolsStore extends Store {
  UserSymbolsStore()
      : symbols = [],
        currentSymbolIndex = -1,
        super();

  List<SymbolDetail> symbols;

  int currentSymbolIndex;

  static const String kSymbolDetailEndpoint =
      'https://iextrading.com/api/1.0/stock/%symbol%/realtime-update';

  static const String kChartEndpoint =
      'https://api.iextrading.com/1.0/stock/%symbol%/chart/1m';

  addUserSymbol(SymbolDetail userSymbol) {
    assert(userSymbol != null, 'User symbol cannot be null.');

    updateModel(() {
      // Check if the symbol already exists.
      final existingSymbolIdx = symbols.indexWhere(
          (SymbolDetail symbol) => symbol.symbol == userSymbol.symbol);
      if (existingSymbolIdx == -1) {
        symbols.add(userSymbol);

        final latestIndex = symbols.length - 1;
        currentSymbolIndex = latestIndex;

        _fetchAndUpdateSymbolDetail(userSymbol);
        _updateAndUpdateSymbolChart(userSymbol);
      } else {
        currentSymbolIndex = existingSymbolIdx;
      }
    });
  }

  _fetchAndUpdateSymbolDetail(SymbolDetail userSymbol) async {
    final endpoint =
        kSymbolDetailEndpoint.replaceFirst('%symbol%', userSymbol.symbol);

    final response = await http.get(endpoint);
    Map<String, dynamic> result = json.decode(response.body);

    assert(response.statusCode == 200,
        'Invalid status code response while fetching ' + endpoint);

    final quote = result['quote'];
    updateModel(() {
      userSymbol.latestPrice = quote['latestPrice'];
      userSymbol.previousClose = quote['previousClose'];
    });
  }

  _updateAndUpdateSymbolChart(SymbolDetail userSymbol) async {
    final endpoint = kChartEndpoint.replaceFirst('%symbol%', userSymbol.symbol);

    final response = await http.get(endpoint);
    List<dynamic> result = json.decode(response.body);

    assert(response.statusCode == 200,
        'Invalid status code response while fetching ' + endpoint);

    updateModel(() {
      var itemIndex = 0;
      userSymbol.charData = result
          .where((dataPoint) => dataPoint['close'] >= 0)
          .map((dataPoint) => ChartDataPoint(
                time: itemIndex++,
                average: dataPoint['close'],
              ))
          .toList();
    });
  }

  resetCurrentSymbol() {
    currentSymbolIndex = -1;
  }

  removeSymbol(SymbolDetail symbol) {
    final symbolIdx = symbols.indexOf(symbol);

    assert(symbolIdx != -1, 'Symbol doesn\'t exist in the user list.');
    updateModel(() {
      symbols.removeAt(symbolIdx);
    });
  }
}
