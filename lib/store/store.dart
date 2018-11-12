import 'package:flutter/widgets.dart';

class Store {
  Store() : _listeners = Set();

  final Set<Function> _listeners;

  // Notify the view that the model has changed.
  // Wrap mutations to the model within a call to [updateModel].
  updateModel(Function doMutation) {
    assert(doMutation != null, 'Callback cannot be null');
    doMutation();
    _listeners.forEach((listener) => listener());
  }

  addListener(Function listener) {
    assert(listener != null, 'Listener cannot be null');
    _listeners.add(listener);
  }

  removeListener(Function listener) {
    assert(listener != null, 'Listener cannot be null');
    _listeners.remove(listener);
  }
}

class StoreProvider extends InheritedWidget {
  const StoreProvider({
    Key key,
    final Map<Type, Store> stores,
    Widget child,
  })  : assert(stores != null),
        assert(child != null),
        _stores = stores,
        super(key: key, child: child);

  final Map<Type, Store> _stores;

  dynamic getStore(Type type) {
    assert(
        _stores.containsKey(type),
        'Tried to get a store for type `' +
            type.toString() +
            '` but it wasn\'t registered in the nearest context.');

    dynamic store = _stores[type];

    assert(
        store.runtimeType == type,
        'Store for type `' +
            type.toString() +
            '` is not a subclass of this type.');
    return store;
  }

  @override
  bool updateShouldNotify(StoreProvider old) => _stores != old._stores;
}

class StoreViewContext<T extends Store> extends StatefulWidget {
  const StoreViewContext({
    Key key,
    this.context,
    this.builder,
  }) : super(key: key);

  final BuildContext context;
  final Widget Function(T) builder;

  @override
  _StoreViewContext createState() => new _StoreViewContext<T>();
}

class _StoreViewContext<T extends Store> extends State<StoreViewContext<T>> {
  StoreProvider _getStoreProvider(BuildContext context) =>
      context.inheritFromWidgetOfExactType(StoreProvider);

  _setState() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    final StoreProvider provider = _getStoreProvider(widget.context);
    final T store = provider.getStore(T) as T;

    // Update the state of the current widget.
    store.addListener(_setState);
  }

  @override
  void dispose() {
    final StoreProvider provider = _getStoreProvider(widget.context);
    final T store = provider.getStore(T) as T;

    // Clean up the listener;
    store.removeListener(_setState);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final StoreProvider provider = _getStoreProvider(widget.context);

    assert(provider != null, 'No store provider.');
    return widget.builder(provider.getStore(T) as T);
  }
}

class StoreInjector<T extends Store> extends StatelessWidget {
  const StoreInjector({
    Key key,
    this.builder,
  }) : super(key: key);

  final Widget Function(T) builder;

  @override
  Widget build(BuildContext context) {
    return StoreViewContext(
      context: context,
      builder: builder,
    );
  }
}
