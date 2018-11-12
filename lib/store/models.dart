
class SearchableSymbol {
  SearchableSymbol({
    this.symbol,
    this.companyName,
  })  : _searchableSymbol = symbol.toLowerCase(),
        _searchableCompanyName = companyName.toLowerCase();

  String symbol;
  String companyName;
  String _searchableSymbol;
  String _searchableCompanyName;

  match(String query) {
    return _searchableCompanyName.startsWith(query) ||
        _searchableSymbol.startsWith(query);
  }
}

class SymbolDetail {
  SymbolDetail({
    this.symbol,
    this.companyName,
    this.previousClose,
    this.latestPrice,
    this.charData = const [],
  });

  String symbol;
  String companyName;
  num previousClose;
  num latestPrice;
  List<ChartDataPoint> charData;
}

class ChartDataPoint {
  ChartDataPoint({this.time, this.average});

  num time;
  num average;
}
