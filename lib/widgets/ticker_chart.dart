import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

import '../store/models.dart';

class TickerChart extends StatelessWidget {
  const TickerChart({
    Key key,
    this.charData,
  })  : assert(charData != null),
        super(key: key);

  final List<ChartDataPoint> charData;

  @override
  Widget build(BuildContext context) {
    List<charts.Series<ChartDataPoint, int>> list = [
      charts.Series<ChartDataPoint, int>(
        id: 'Value',
        colorFn: (_, __) => charData.last.average > charData.first.average
            ? charts.MaterialPalette.green.shadeDefault
            : charts.MaterialPalette.red.shadeDefault,
        domainFn: (ChartDataPoint dataPoint, _) {
          return dataPoint.time;
        },
        measureFn: (ChartDataPoint dataPoint, _) {
          return dataPoint.average;
        },
        data: charData,
      )
    ];
    return charts.LineChart(
      list,
      animate: false,
      defaultInteractions: false,
    );
  }
}
