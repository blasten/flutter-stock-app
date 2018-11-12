import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../store/models.dart';
import 'ticker_chart.dart';

class TickerCarouselItem extends StatefulWidget {
  const TickerCarouselItem({
    Key key,
    this.symbol,
    this.onRemove,
    this.editing = false,
  })  : assert(symbol != null),
        super(key: key);

  final SymbolDetail symbol;

  final GestureTapCallback onRemove;

  final bool editing;

  @override
  _TickerCarouselItemState createState() => _TickerCarouselItemState();
}

class _TickerCarouselItemState extends State<TickerCarouselItem>
    with TickerProviderStateMixin {
  // The animation when the user attempts to remove the carousel items.
  AnimationController _shakeAnimationController;

  @override
  void initState() {
    super.initState();

    _shakeAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );

    _shakeAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _shakeAnimationController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _shakeAnimationController.forward();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Container card = Container(
      margin: const EdgeInsets.all(2.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(
          const Radius.circular(5.0),
        ),
      ),
      child: _InnerContent(symbol: widget.symbol),
    );

    if (widget.editing) {
      _shakeAnimationController.forward();

      return AnimatedBuilder(
        animation: _shakeAnimationController,
        builder: (BuildContext context, Widget _widget) {
          return Transform.rotate(
            angle: (_shakeAnimationController.value - 0.5) * 0.03,
            child: _widget,
          );
        },
        child: Stack(
          overflow: Overflow.visible,
          children: <Widget>[
            card,
            Positioned(
              child: GestureDetector(
                behavior: HitTestBehavior.deferToChild,
                onTap: widget.onRemove,
                child: _RemoveButton(),
              ),
              top: 10.0,
              right: 10.0,
              width: 24.0,
              height: 24.0,
            ),
          ],
        ),
      );
    } else {
      _shakeAnimationController.stop();
      return card;
    }
  }

  @override
  dispose() {
    _shakeAnimationController.dispose();
    super.dispose();
  }
}

class _InnerContent extends StatelessWidget {
  _InnerContent({
    Key key,
    this.symbol,
  })  : assert(symbol != null),
        _numberFormatter = NumberFormat("#,##0.00", "en_US"),
        super(key: key);

  final SymbolDetail symbol;

  final NumberFormat _numberFormatter;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[
      Text(
        symbol.symbol,
        style: TextStyle(
          fontWeight: FontWeight.w100,
          fontSize: 18.0,
        ),
      ),
      Text(symbol.companyName),
    ];

    if (symbol.latestPrice != null) {
      final priceDelta = symbol.latestPrice - symbol.previousClose;
      final percentageDelta = priceDelta / symbol.previousClose * 100;
      final priceColor = priceDelta >= 0 ? Colors.green[600] : Colors.red[600];

      // Add the price and gain/loss label.
      children.addAll([
        Container(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            _numberFormatter.format(symbol.latestPrice),
            style: TextStyle(
              fontWeight: FontWeight.w100,
              fontSize: 32.0,
            ),
          ),
        ),
        Row(
          children: <Widget>[
            Icon(
              IconData(
                priceDelta >= 0 ? 0xe316 : 0xe5cf,
                fontFamily: 'MaterialIcons',
              ),
              color: priceColor,
            ),
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  '${_numberFormatter.format(priceDelta)} (${_numberFormatter.format(percentageDelta)}%)',
                  style: TextStyle(
                    color: priceColor,
                    fontSize: 18.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ]);
    }

    if (symbol.charData.length > 0) {
      // Add the chart.
      children.add(
        Expanded(
          child: TickerChart(
            charData: symbol.charData,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

class _RemoveButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          color: Colors.red[300],
          borderRadius: BorderRadius.all(
            const Radius.circular(12.0),
          ),
        ),
        child: Icon(
          IconData(
            0xe5cd,
            fontFamily: 'MaterialIcons',
          ),
          color: Colors.white,
          size: 16.0,
        ));
  }
}
