import 'package:flutter/material.dart';

import '../store/models.dart';
import '../store/store.dart';
import '../store/app_stores.dart';
import 'ticker_carousel_item.dart';

class TickerCarousel extends StatefulWidget {
  TickerCarousel({Key key, this.onRemoveItem}) : super(key: key);

  final void Function(int index) onRemoveItem;

  @override
  _TickerCarouselState createState() => new _TickerCarouselState();
}

class _TickerCarouselState extends State<TickerCarousel> {
  PageController _pageController;

  bool _editing = false;

  @override
  initState() {
    super.initState();
    _pageController = PageController(
      initialPage: 0,
      keepPage: false,
      viewportFraction: 0.5,
    );
  }

  @override
  dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StoreInjector<UserSymbolsStore>(
      builder: (UserSymbolsStore userSymbols) {
        if (_pageController.hasClients &&
            userSymbols.currentSymbolIndex != -1) {
          _pageController.animateToPage(
            userSymbols.currentSymbolIndex,
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeOut,
          );
          userSymbols.resetCurrentSymbol();
        }
        return GestureDetector(
          onLongPress: _toggleEditingMode,
          child: Container(
            child: PageView.builder(
              physics: AlwaysScrollableScrollPhysics(),
              pageSnapping: true,
              controller: _pageController,
              itemCount: userSymbols.symbols.length,
              itemBuilder: (context, index) {
                final item = userSymbols.symbols[index];
                return itemBuilder(item, onRemove: () {
                  userSymbols.removeSymbol(item);
                });
              },
            ),
          ),
        );
      },
    );
  }

  void _toggleEditingMode() {
    setState(() {
      _editing = !_editing;
    });
  }

  itemBuilder(SymbolDetail symbol, {@required GestureTapCallback onRemove}) {
    return AnimatedBuilder(
      key: Key('carousel_item_' + symbol.symbol),
      animation: _pageController,
      builder: (context, child) {
        double value = 1.0;
        return Container(
          width: Curves.easeOut.transform(value) * 250,
          child: child,
        );
      },
      child: TickerCarouselItem(
        symbol: symbol,
        editing: _editing,
        onRemove: onRemove,
      ),
    );
  }
}
