import 'package:flutter/material.dart';

class TickerAppBar extends StatefulWidget implements PreferredSizeWidget {
  const TickerAppBar({
    Key key,
    this.onSearchInputFocusChanged,
    this.iconTheme,
    this.textTheme,
    this.textInputController,
  })  : assert(onSearchInputFocusChanged != null),
        assert(textInputController != null),
        primary = true,
        preferredSize = const Size.fromHeight(kToolbarHeight),
        super(key: key);

  final void Function(bool focused) onSearchInputFocusChanged;

  final TextEditingController textInputController;

  final bool primary;

  final IconThemeData iconTheme;

  final TextTheme textTheme;

  @override
  final Size preferredSize;

  @override
  _TickerAppState createState() => _TickerAppState();
}

class _TickerAppState extends State<TickerAppBar>
    with SingleTickerProviderStateMixin {
  // Animation when the user types some content in the input.
  AnimationController _animationController;

  // Animation for the fill color of the text input.
  Animation<Color> _inputFillColorTween;

  // Animation for the icon color of the text input.
  Animation<Color> _inputIconColorTween;

  FocusNode _searchInputFocusNode;

  @override
  initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );

    _inputFillColorTween = ColorTween(
            begin: Colors.white.withOpacity(0.3),
            end: Colors.white.withOpacity(0.9))
        .animate(_animationController)
          ..addListener(() {
            setState(() {});
          });

    _inputIconColorTween = ColorTween(
      begin: Colors.white.withOpacity(0.3),
      end: Colors.grey[500],
    ).animate(_animationController)
      ..addListener(() {
        setState(() {});
      });

    widget.textInputController?.addListener(_onTextInputValueChanged);

    _searchInputFocusNode = FocusNode();
    _searchInputFocusNode.addListener(_onSearchFocusNodeChanged);
  }

  @override
  dispose() {
    super.dispose();

    _animationController?.dispose();
    _searchInputFocusNode?.removeListener(_onSearchFocusNodeChanged);
    widget.textInputController?.removeListener(_onTextInputValueChanged);
  }

  _onSearchFocusNodeChanged() {
    widget.onSearchInputFocusChanged(_searchInputFocusNode.hasFocus);
  }

  _onTextInputValueChanged() {
    if (widget.textInputController == null) {
      return;
    }
    final String text = widget.textInputController.text;
    if (text.isNotEmpty) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Container(
        child: SafeArea(
          top: true,
          child: Container(
            margin: const EdgeInsets.only(
              left: 16.0,
              right: 16.0,
            ),
            child: Container(
              decoration: BoxDecoration(
                  color: _inputFillColorTween?.value,
                  borderRadius: BorderRadius.all(const Radius.circular(5.0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 20.0,
                    ),
                  ]),
              child: Center(
                child: TextField(
                  focusNode: _searchInputFocusNode,
                  controller: widget.textInputController,
                  style: TextStyle(
                    fontSize: 18.0,
                    color: Colors.black,
                  ),
                  decoration: InputDecoration(
                    icon: Container(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: Icon(
                          IconData(
                            0xe8b6,
                            fontFamily: 'MaterialIcons',
                          ),
                          color: _inputIconColorTween?.value,
                        )),
                    border: InputBorder.none,
                    hintText: 'Type a company name',
                    hintStyle: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
