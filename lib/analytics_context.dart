import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Passes data map down the tree. Children fold their context into this one.
/// Can be accessed with [AnalyticsContext.of] and consumed directly. Or use
/// [AnalyticsContext.report] to report directly
class AnalyticsContext extends StatefulWidget {
  const AnalyticsContext({
    Key? key,
    required this.child,
    required this.data,
  }) : super(key: key);

  final Widget child;

  final Map<String, String> data;

  static Map<String, String> of(BuildContext context) =>
      context.read<_AnalyticsContextState>()._computedData;

  static Future<void> report(
    BuildContext context, {
    required String name,
    required Map<String, String> data,
  }) async {
    final computedData = _AnalyticsContextState._buildData(context.read, data);

    print('AnalyticsContext.report(name: $name, data: $computedData)');
  }

  @override
  _AnalyticsContextState createState() => _AnalyticsContextState();
}

class _AnalyticsContextState extends State<AnalyticsContext> {
  Map<String, String> get _computedData =>
      _buildData(context.read, widget.data);

  /// Locate parent [AnalyticsContext], if it exists, and merge it's data with
  /// some new data. Safe to use even if there is no parent [AnalyticsContext]
  static Map<String, String> _buildData(
      Locator locator, Map<String, String> data) {
    var computedData = <String, String>{};

    try {
      computedData.addAll(locator<_AnalyticsContextState>()._computedData);
    } catch (_) {
      ///
    } finally {
      computedData.addAll(data);
    }

    return computedData;
  }

  @override
  Widget build(BuildContext context) {
    return Provider<_AnalyticsContextState>.value(
      value: this,
      child: widget.child,
    );
  }
}

extension AnalyticsContextX on BuildContext {
  Map<String, String> get analyticsData => AnalyticsContext.of(this);

  Future<void> analyticsEvent(
    String name, {
    Map<String, String> data = const {},
  }) =>
      AnalyticsContext.report(this, name: name, data: data);
}
