import 'package:flutter/material.dart';

import '../store/models.dart';
import '../store/store.dart';
import '../store/app_stores.dart';

class TickerSearchResults extends StatefulWidget {
  TickerSearchResults({
    Key key,
    this.textInputController,
  })  : assert(textInputController != null),
        super(key: key);

  final TextEditingController textInputController;

  @override
  _TickerSearchResults createState() => _TickerSearchResults();
}

class _TickerSearchResults extends State<TickerSearchResults> {
  List<SearchableSymbol> _lastResults;

  @override
  void initState() {
    super.initState();
    _lastResults = [];
  }

  @override
  Widget build(BuildContext context) {
    return StoreInjector<UserSymbolsStore>(
      builder: (UserSymbolsStore userSymbols) {
        return StoreInjector<SearchableSymbolsStore>(
          builder: (SearchableSymbolsStore searchableSymbols) {
            final searchableQuery =
                widget.textInputController.text.toLowerCase();
            final List<SearchableSymbol> results = searchableQuery.isEmpty
                ? []
                : searchableSymbols.symbols
                    .where((item) => item.match(searchableQuery))
                    .toList();
            final currentResults =
                searchableQuery.isEmpty ? _lastResults : results;

            _lastResults = results;

            return GestureDetector(
                onTap: () {
                  // Unfocus the search input.
                  FocusScope.of(context).requestFocus(FocusNode());
                },
                child: SizedBox.expand(
                  child: ListView.builder(
                    primary: true,
                    itemCount: currentResults.length,
                    itemExtent: 65.0,
                    itemBuilder: (BuildContext context, int index) {
                      final item = currentResults[index];
                      return _TickerSearchResultItem(
                        key: Key('result_item' + item.symbol),
                        companyName: item.companyName,
                        symbol: item.symbol,
                        onTap: () {
                          widget.textInputController.clear();
                          // (flutter/issues/7247) Hide the keyboard.
                          FocusScope.of(context).requestFocus(FocusNode());

                          // Add the symbol to the user list.
                          userSymbols.addUserSymbol(SymbolDetail(
                            symbol: item.symbol,
                            companyName: item.companyName,
                          ));
                        },
                      );
                    },
                  ),
                ));
          },
        );
      },
    );
  }
}

class _TickerSearchResultItem extends StatelessWidget {
  const _TickerSearchResultItem({
    Key key,
    this.companyName,
    this.symbol,
    this.onTap,
  }) : super(key: key);

  final String companyName;

  final String symbol;

  final GestureTapCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.only(
          left: 20.0,
          right: 20.0,
        ),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        companyName,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w200,
                          fontSize: 18.0,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Text(symbol,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0,
                          color: Colors.white,
                        ))
                  ],
                ),
              ),
              Divider(
                color: Colors.white,
                height: 1,
              )
            ]),
      ),
    );
  }
}
