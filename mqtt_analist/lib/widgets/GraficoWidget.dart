import 'package:flutter/material.dart';
import 'package:mqtt_analist/main.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class GraficoWidget extends StatefulWidget {
  const GraficoWidget(
      {super.key,
      required this.title,
      required this.data,
      required this.safeValue,
      required this.lineColor});

  final String title;
  final List<SensorData> data;
  final int safeValue;
  final Color lineColor;

  @override
  State<GraficoWidget> createState() => _GraficoWidgetState();
}

class _GraficoWidgetState extends State<GraficoWidget> {
  @override
  Widget build(BuildContext context) {
    return SfCartesianChart(
      // Initialize category axis
      primaryXAxis: CategoryAxis(),
      title: ChartTitle(text: widget.title),
      legend: Legend(
        isVisible: true,
        overflowMode: LegendItemOverflowMode.wrap,
      ),
      series: <LineSeries<SensorData, String>>[
        LineSeries<SensorData, String>(
          dataSource: widget.data,
          animationDuration: 0,
          legendItemText: "Safe",
          color: Colors.red,
          width: 1,
          xValueMapper: (SensorData s, _) => s.date,
          yValueMapper: (SensorData s, _) => widget.safeValue,
        ),
        LineSeries<SensorData, String>(
          // Bind data source
          legendItemText: "Valor",
          isVisibleInLegend: true,
          legendIconType: LegendIconType.horizontalLine,
          dataSource: widget.data,
          animationDuration: 0,
          color: widget.lineColor,
          width: 0.5,
          xValueMapper: (SensorData sensor, _) => sensor.date,
          yValueMapper: (SensorData sensor, _) => sensor.value,
        ),
      ],
    );
  }
}

// class SensorData {
//   SensorData(this.date, this.value);
//   final String date;
//   final int value;
// }
