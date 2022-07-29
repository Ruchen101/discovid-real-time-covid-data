import 'package:flutter/material.dart';
import 'package:discovid/constants.dart';
import 'package:discovid/charts/SimpleTimeSeriesChart.dart';
import 'package:discovid/charts/HorizontalBarLabelChart.dart';
import 'package:charts_flutter/flutter.dart';

import 'package:charts_flutter/flutter.dart' as charts;

class StatsScreen extends StatelessWidget {

  static const String id = 'stats_screen';


  HorizontalBarLabelChart horizontalBarLabelChart = HorizontalBarLabelChart(
    _createSampleDataForBarChart(),
    animate: true,
  );
  //horizontalBarLabelChart.


  SimpleTimeSeriesChart simpleTimeSeriesChart = SimpleTimeSeriesChart(
    _createSampleDataForLineGraph(),
    animate: true,
  );


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: kGradient,
              begin: Alignment.bottomLeft,
              end: Alignment.topRight),
        ),
        child: SafeArea(
          child: Column(
            children: <Widget>[
              Expanded(
                //call time series charts
                child: Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(
                        Radius.circular(20.0),
                      ),
                      boxShadow: [
                        shadowsForStatCards,
                      ],
                    ),
                    child: charts.TimeSeriesChart(
                      simpleTimeSeriesChart.seriesListTime,
                      animate: simpleTimeSeriesChart.animate,
                      behaviors: [
                        charts.ChartTitle('Cases'),
                        charts.ChartTitle('Confirmed Cases',
                            behaviorPosition: charts.BehaviorPosition.start),
                        charts.ChartTitle('Time',
                            behaviorPosition: charts.BehaviorPosition.bottom)
                      ],
                      // Optionally pass in a [DateTimeFactory] used by the chart. The factory
                      // should create the same type of [DateTime] as the data provided. If none
                      // specified, the default creates local date time.
                      dateTimeFactory: const charts.LocalDateTimeFactory(),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(
                        Radius.circular(20.0),
                      ), boxShadow: [
                      shadowsForStatCards,
                    ],
                    ),
                    child: charts.BarChart(
                      horizontalBarLabelChart.seriesListBar,
                      animate: horizontalBarLabelChart.animate,
                      behaviors: [
                        charts.ChartTitle('Cases per province'),
                        charts.ChartTitle('Province',
                            behaviorPosition: charts.BehaviorPosition.start),
                        charts.ChartTitle('Number of cases',
                            behaviorPosition: charts.BehaviorPosition.bottom)
                      ],
                      vertical: false,
                      // Set a bar label decorator.
                      // Example configuring different styles for inside/outside:
                      //       barRendererDecorator: new charts.BarLabelDecorator(
                      //          insideLabelStyleSpec: new charts.TextStyleSpec(...),
                      //          outsideLabelStyleSpec: new charts.TextStyleSpec(...)),
                      barRendererDecorator:
                      new charts.BarLabelDecorator<String>(),
                      // Hide domain axis.
                      domainAxis: new charts.OrdinalAxisSpec(
                          renderSpec: new charts.NoneRenderSpec()),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );



  }

  /// Create one series with time sample hard coded data. For line graph
  static List<charts.Series<TimeSeriesCases, DateTime>> _createSampleDataForLineGraph() {
    final data = [
      //March Cases
      TimeSeriesCases(DateTime(2020, 3, 3), 0),
      TimeSeriesCases(DateTime(2020, 3, 4), 0),
      TimeSeriesCases(DateTime(2020, 3, 5), 1),
      TimeSeriesCases(DateTime(2020, 3, 6), 1),
      TimeSeriesCases(DateTime(2020, 3, 7), 2),
      TimeSeriesCases(DateTime(2020, 3, 8), 3),
      TimeSeriesCases(DateTime(2020, 3, 9), 7),
      TimeSeriesCases(DateTime(2020, 3, 10), 7),
      TimeSeriesCases(DateTime(2020, 3, 11), 13),
      TimeSeriesCases(DateTime(2020, 3, 12), 16),
      TimeSeriesCases(DateTime(2020, 3, 13), 24),
      TimeSeriesCases(DateTime(2020, 3, 14), 38),
      TimeSeriesCases(DateTime(2020, 3, 15), 51),
      TimeSeriesCases(DateTime(2020, 3, 16), 62),
      TimeSeriesCases(DateTime(2020, 3, 17), 85),
      TimeSeriesCases(DateTime(2020, 3, 18), 116),
      TimeSeriesCases(DateTime(2020, 3, 19), 150),
      TimeSeriesCases(DateTime(2020, 3, 20), 202),
      TimeSeriesCases(DateTime(2020, 3, 21), 240),
      TimeSeriesCases(DateTime(2020, 3, 21), 270),
      TimeSeriesCases(DateTime(2020, 3, 23), 402),
      TimeSeriesCases(DateTime(2020, 3, 24), 554),
      TimeSeriesCases(DateTime(2020, 3, 25), 709),
      TimeSeriesCases(DateTime(2020, 3, 26), 927),
      TimeSeriesCases(DateTime(2020, 3, 27), 1170),
      TimeSeriesCases(DateTime(2020, 3, 28), 1187),
      TimeSeriesCases(DateTime(2020, 3, 29), 1280),
      TimeSeriesCases(DateTime(2020, 3, 30), 1326),
      TimeSeriesCases(DateTime(2020, 3, 31), 1353),

      //April cases
      TimeSeriesCases(DateTime(2020, 4, 1), 1380),
      TimeSeriesCases(DateTime(2020, 4, 2), 1462),
      TimeSeriesCases(DateTime(2020, 4, 3), 1505),
      TimeSeriesCases(DateTime(2020, 4, 4), 1585),
      TimeSeriesCases(DateTime(2020, 4, 5), 1655),
      TimeSeriesCases(DateTime(2020, 4, 6), 1686),
      TimeSeriesCases(DateTime(2020, 4, 7), 1749),
      TimeSeriesCases(DateTime(2020, 4, 8), 1845),
      TimeSeriesCases(DateTime(2020, 4, 9), 1934),
      TimeSeriesCases(DateTime(2020, 4, 10), 2003),
      TimeSeriesCases(DateTime(2020, 4, 11), 2028),
      TimeSeriesCases(DateTime(2020, 4, 12), 2173),
      TimeSeriesCases(DateTime(2020, 4, 13), 2272),
      TimeSeriesCases(DateTime(2020, 4, 14), 2415),
      TimeSeriesCases(DateTime(2020, 4, 15), 2506),
      TimeSeriesCases(DateTime(2020, 4, 16), 2783),
      TimeSeriesCases(DateTime(2020, 4, 17), 2783),
      TimeSeriesCases(DateTime(2020, 4, 18), 3034),
      TimeSeriesCases(DateTime(2020, 4, 19), 3158),
      TimeSeriesCases(DateTime(2020, 4, 20), 3300),
      TimeSeriesCases(DateTime(2020, 4, 21), 3465),
      TimeSeriesCases(DateTime(2020, 4, 21), 3635),
      TimeSeriesCases(DateTime(2020, 4, 23), 3953),
      TimeSeriesCases(DateTime(2020, 4, 24), 4220),
      TimeSeriesCases(DateTime(2020, 4, 25), 4361),
      TimeSeriesCases(DateTime(2020, 4, 26), 4546),
      TimeSeriesCases(DateTime(2020, 4, 27), 4793),
      TimeSeriesCases(DateTime(2020, 4, 28), 4996),
      TimeSeriesCases(DateTime(2020, 4, 29), 5350),
      TimeSeriesCases(DateTime(2020, 4, 30), 5647),

      //MAY CASES
      TimeSeriesCases(DateTime(2020, 5, 1), 5951),
      TimeSeriesCases(DateTime(2020, 5, 2), 6336),
      TimeSeriesCases(DateTime(2020, 5, 3), 6783),
      TimeSeriesCases(DateTime(2020, 5, 4), 7220),

    ];

    return [
      new charts.Series<TimeSeriesCases, DateTime>(
        id: 'cases',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (TimeSeriesCases cases, _) => cases.time,
        measureFn: (TimeSeriesCases cases, _) => cases.cases,
        data: data,
      )
    ];
  }

  /// Create one series with bar chart sample hard coded data.
  static List<charts.Series<OrdinalProvinceCases, String>> _createSampleDataForBarChart() {
    final data = [
      OrdinalProvinceCases('Western Cape', 3362),
      OrdinalProvinceCases('Gauteng', 1661),
      OrdinalProvinceCases('KwaZulu-Natal', 1106),
      OrdinalProvinceCases('Eastern Cape', 814),
      OrdinalProvinceCases('Free State', 125),
      OrdinalProvinceCases('Mpumalanga', 53),
      OrdinalProvinceCases('Limpopo', 39),
      OrdinalProvinceCases('North West', 35),
      OrdinalProvinceCases('Northern Cape', 25),
    ];

    return [
      new charts.Series<OrdinalProvinceCases, String>(
          id: 'Provinces',
          domainFn: (OrdinalProvinceCases provinces, _) => provinces.year,
          measureFn: (OrdinalProvinceCases provinces, _) => provinces.provinces,
          data: data,
          colorFn: (_, __) => charts.MaterialPalette.indigo.shadeDefault,

          //colorFn: charts.ColorUtil.fromDartColor(Colors.white),
          // Set a label accessor to control the text of the bar label.
          labelAccessorFn: (OrdinalProvinceCases provinces, _) =>
          '${provinces.year}: ${provinces.provinces.toString()}')
    ];
  }
}


