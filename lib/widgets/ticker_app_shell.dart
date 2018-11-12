import 'package:flutter/material.dart';

import 'ticker_app_bar.dart';
import 'ticker_carousel.dart';
import 'ticker_search_results.dart';

class TickerAppShell extends StatefulWidget {
  TickerAppShell({
    Key key,
    this.title,
  }) : super(key: key);

  // The title of the page.
  final String title;

  @override
  _TickerAppShell createState() => new _TickerAppShell();
}

class _TickerAppShell extends State<TickerAppShell>
    with SingleTickerProviderStateMixin {
  // The duration of the animation.
  final animationDuration = const Duration(milliseconds: 200);

  TextEditingController _textInputController;

  bool _userIsSearching = false;

  @override
  initState() {
    super.initState();

    _textInputController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomLeft,
            colors: [
              Colors.grey[600],
              Colors.black,
            ],
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: TickerAppBar(
              onSearchQueryChanged: (String query) {
                setState(() {
                  _userIsSearching = query.isNotEmpty;
                });
              },
              textInputController: _textInputController),
          body: Stack(
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  AnimatedContainer(
                    transform: Matrix4.translationValues(
                      0.0,
                      _userIsSearching ? 400.0 : 0.0,
                      0.0,
                    ),
                    duration: animationDuration,
                    curve: Curves.easeInOut,
                    child: AnimatedOpacity(
                      opacity: _userIsSearching ? 0.0 : 1.0,
                      duration: animationDuration,
                      curve: Curves.easeInOut,
                      child: TickerBottomCarousel(),
                    ),
                  ),
                ],
              ),
              Positioned(
                left: 0.0,
                right: 0.0,
                top: 0.0,
                bottom: 0.0,
                child: IgnorePointer(
                  ignoring: !_userIsSearching,
                  child: AnimatedOpacity(
                      opacity: _userIsSearching ? 1.0 : 0.0,
                      duration: animationDuration,
                      curve: Curves.easeIn,
                      child: TickerSearchResults(
                        textInputController: _textInputController,
                      )),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class TickerBottomCarousel extends StatefulWidget {
  @override
  _TickerBottomCarousel createState() => new _TickerBottomCarousel();
}

class _TickerBottomCarousel extends State<TickerBottomCarousel> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20.0),
      child: SizedBox(
        height: 400.0,
        child: TickerCarousel(),
      ),
    );
  }
}
