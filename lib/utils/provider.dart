import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';

// This is a simplified provider implementation for development purposes
// In a real app, use the provider package from pub.dev

/// A simple implementation of ChangeNotifierProvider
/// This serves as a local alternative to the package:provider
class ChangeNotifierProvider<T extends ChangeNotifier> extends StatefulWidget {
  final T Function(BuildContext) create;
  final Widget child;

  const ChangeNotifierProvider({
    Key? key,
    required this.create,
    required this.child,
  }) : super(key: key);

  /// Get the provider value from the context
  static T of<T extends ChangeNotifier>(BuildContext context,
      {bool listen = true}) {
    final provider = listen
        ? context.dependOnInheritedWidgetOfExactType<_InheritedProvider<T>>()
        : context
            .getElementForInheritedWidgetOfExactType<_InheritedProvider<T>>()
            ?.widget as _InheritedProvider<T>?;

    if (provider == null) {
      throw FlutterError(
        'ChangeNotifierProvider.of() called with a context that does not contain a $T.\n'
        'Make sure the $T is provided higher up in the widget tree.',
      );
    }

    return provider.notifier!;
  }

  @override
  _ChangeNotifierProviderState<T> createState() =>
      _ChangeNotifierProviderState<T>();
}

class _ChangeNotifierProviderState<T extends ChangeNotifier>
    extends State<ChangeNotifierProvider<T>> {
  late T _notifier;

  @override
  void initState() {
    super.initState();
    _notifier = widget.create(context);
  }

  @override
  void dispose() {
    _notifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _InheritedProvider<T>(
      notifier: _notifier,
      child: widget.child,
    );
  }
}

class _InheritedProvider<T extends Listenable> extends InheritedNotifier<T> {
  const _InheritedProvider({
    Key? key,
    required T notifier,
    required Widget child,
  }) : super(key: key, notifier: notifier, child: child);
}

/// Consumer widget that rebuilds when the ChangeNotifier changes
class Consumer<T extends ChangeNotifier> extends StatelessWidget {
  final Widget Function(BuildContext context, T value, Widget? child) builder;
  final Widget? child;

  const Consumer({
    Key? key,
    required this.builder,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return builder(
      context,
      ChangeNotifierProvider.of<T>(context),
      child,
    );
  }
}

/// Extension for BuildContext to easily access providers
extension ProviderExtension on BuildContext {
  T watch<T extends ChangeNotifier>() {
    return ChangeNotifierProvider.of<T>(this);
  }

  T read<T extends ChangeNotifier>() {
    return ChangeNotifierProvider.of<T>(this, listen: false);
  }
}

class Provider {
  static T of<T extends ChangeNotifier>(BuildContext context,
      {bool listen = true}) {
    return ChangeNotifierProvider.of<T>(context, listen: listen);
  }
}
