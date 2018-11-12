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

  bool _searchTextInputFocus = false;

  @override
  initState() {
    super.initState();

    _textInputController = TextEditingController();
    _textInputController.addListener(_searchTextInputHandler);
  }

  @override
  dispose() {
    _textInputController?.removeListener(_searchTextInputHandler);
    super.dispose();
  }

  _searchTextInputHandler() {
    setState(() {
      _userIsSearching = _textInputController.text.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool userIsSearching = _userIsSearching || _searchTextInputFocus;
    return Container(
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
        resizeToAvoidBottomPadding : false,
        backgroundColor: Colors.transparent,
        appBar: TickerAppBar(
          onSearchInputFocusChanged: (bool focus) {
            setState(() {
              _searchTextInputFocus = focus;
            });
          },
          textInputController: _textInputController,
        ),
        body: Stack(
          children: <Widget>[
            Positioned(
              left: 0.0,
              right: 0.0,
              bottom: 0.0,
              child: AnimatedContainer(
                transform: Matrix4.translationValues(
                  0.0,
                  userIsSearching ? 400.0 : 0.0,
                  0.0,
                ),
                duration: animationDuration,
                curve: Curves.easeInOut,
                child: AnimatedOpacity(
                  opacity: userIsSearching ? 0.0 : 1.0,
                  duration: animationDuration,
                  curve: Curves.easeInOut,
                  child: TickerBottomCarousel(),
                ),
              ),
            ),
            Positioned(
              left: 0.0,
              right: 0.0,
              top: 0.0,
              bottom: 0.0,
              child: IgnorePointer(
                ignoring: !userIsSearching,
                child: AnimatedOpacity(
                    opacity: userIsSearching ? 1.0 : 0.0,
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
