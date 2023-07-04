import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mqtt_analist/widgets/GraficoWidget.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Greenair monitor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.greenAccent),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Home'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  int limit = 200;
  int factor = 1;
  String time = "";
  List<SensorData> oldDataMq2 = [];
  List<SensorData> oldDataMq7 = [];

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  void initState() {
    Timer mytimer = Timer.periodic(Duration(seconds: 2), (timer) {
      DateTime timenow = DateTime.now(); //get current date and time
      time = timenow.hour.toString() +
          ":" +
          timenow.minute.toString() +
          ":" +
          timenow.second.toString();
      setState(() {});
    });
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              FutureBuilder(
                  future: getDataMq2(),
                  builder: ((context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      var json = jsonDecode(snapshot.data);
                      List<SensorData> data = [];
                      for (var element in json) {
                        data.add(SensorData(element[1], element[0]));
                      }
                      oldDataMq2 = data;
                      return GraficoWidget(
                          title: "Sensor de fumaça",
                          safeValue: 15,
                          lineColor: Colors.cyan.shade900,
                          data: data);
                    }
                    if (oldDataMq2 == []) {
                      return Text('carregando...');
                    } else {
                      return GraficoWidget(
                          title: "Sensor de fumaça",
                          safeValue: 15,
                          lineColor: Colors.cyan.shade900,
                          data: oldDataMq2);
                    }
                  })),
              FutureBuilder(
                  future: getDataMq7(),
                  builder: ((context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      var json = jsonDecode(snapshot.data);
                      List<SensorData> data = [];
                      for (var element in json) {
                        data.add(SensorData(element[1], element[0]));
                      }
                      oldDataMq7 = data;

                      return GraficoWidget(
                          title: "Sensor de gás",
                          safeValue: 25,
                          lineColor: Colors.deepPurple,
                          data: data);
                    }
                    if (oldDataMq7 == []) {
                      return Text('carregando...');
                    } else {
                      return GraficoWidget(
                          title: "Sensor de gás",
                          safeValue: 25,
                          lineColor: Colors.deepPurple,
                          data: oldDataMq7);
                    }
                  })),
              DropdownButton(
                  value: limit,
                  onChanged: (int? value) {
                    setState(() {
                      limit = value!;
                      if (value == 200) {
                        factor = 1;
                      } else if (value == 500) {
                        factor = 2;
                      } else if (value == 700) {
                        factor = 3;
                      } else if (value == 1000) {
                        factor = 4;
                      }
                    });
                  },
                  items: dropdownItems)
            ],
          ),
        ),
      ),
    );
  }

  List<DropdownMenuItem<int>> get dropdownItems {
    List<DropdownMenuItem<int>> menuItems = [
      const DropdownMenuItem(value: 200, child: Text("200")),
      const DropdownMenuItem(value: 500, child: Text("500")),
      const DropdownMenuItem(value: 700, child: Text("700")),
      const DropdownMenuItem(value: 1000, child: Text("1000")),
    ];
    return menuItems;
  }

  Future<dynamic> getDataMq2() async {
    var request = http.Request('GET', Uri.parse("urlBackend"));
    var headers = {'Authorization': 'Bearer authToken'};
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      return await response.stream.bytesToString();
    }
    return null;
  }

  Future<dynamic> getDataMq7() async {
    var request = http.Request('GET', Uri.parse("urlBackend"));
    var headers = {'Authorization': 'Bearer authToken'};
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      return await response.stream.bytesToString();
    }
    return null;
  }

  Widget grafico(String title, int safeValue, Color lineColor, data) {
    return SfCartesianChart(
      // Initialize category axis
      primaryXAxis: CategoryAxis(),
      title: ChartTitle(text: title),
      legend: Legend(
        isVisible: true,
        overflowMode: LegendItemOverflowMode.wrap,
      ),
      series: <LineSeries<SensorData, String>>[
        LineSeries<SensorData, String>(
          dataSource: data,
          animationDuration: 0,
          legendItemText: "Safe",
          color: Colors.red,
          width: 1,
          xValueMapper: (SensorData s, _) => s.date,
          yValueMapper: (SensorData s, _) => safeValue,
        ),
        LineSeries<SensorData, String>(
          // Bind data source
          legendItemText: "Valor",
          isVisibleInLegend: true,
          legendIconType: LegendIconType.horizontalLine,
          dataSource: data,
          animationDuration: 0,
          color: lineColor,
          width: 0.5,
          xValueMapper: (SensorData sensor, _) => sensor.date,
          yValueMapper: (SensorData sensor, _) => sensor.value,
        ),
      ],
    );
  }
}

class SensorData {
  SensorData(this.date, this.value);
  final String date;
  final int value;
}
