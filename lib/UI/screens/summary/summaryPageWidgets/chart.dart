import 'package:auto_size_text/auto_size_text.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:ynotes/classes.dart';
import 'dart:math';

class SummaryChart extends StatefulWidget {
  final List<Grade> lastGrades;

  SummaryChart(
    this.lastGrades, {
    Key key,
  }) : super(key: key);
  @override
  _SummaryChartState createState() => _SummaryChartState();
}

class _SummaryChartState extends State<SummaryChart> {
  List<Grade> _grades = List();
  initState() {
    super.initState();
    if (widget.lastGrades != null) {
      _grades.addAll(widget.lastGrades);
      _grades.sort((a, b) => a.dateSaisie.compareTo(b.dateSaisie));
      if (_grades.length > 10) {
        _grades = _grades.sublist(_grades.length - 10, _grades.length);
      }
    }
  }

  getMax() {
    List<double> values = _grades
        .map((grade) =>
            double.parse(grade.valeur.replaceAll(',', '.')) * 20 / double.parse(grade.noteSur.replaceAll(',', '.')))
        .toList();
    //Reduce values size
    values = values.sublist(0, (_grades.length > 10 ? 10 : _grades.length));
    if (values != null && values.length > 0) {
      return values.reduce(max) ?? 20;
    } else {
      return 20;
    }
  }

  getMin() {
    List<double> values = _grades
        .map((grade) =>
            double.parse(grade.valeur.replaceAll(',', '.')) * 20 / double.parse(grade.noteSur.replaceAll(',', '.')))
        .toList();
    //Reduce values size
    values = values.sublist(0, (_grades.length > 10 ? 10 : _grades.length));
    if (values != null && values.length > 0) {
      return values.reduce(min) ?? 0;
    } else {
      return 0;
    }
  }

  toDouble(Grade grade) {
    double toReturn;
    if (!grade.letters) {
      toReturn = (double.tryParse(grade.valeur.replaceAll(",", ".")) *
          20 /
          double.tryParse(grade.noteSur.replaceAll(",", ".")));
      return toReturn;
    }
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context);
    return Card(
      color: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      child: (_grades != null && (_grades.length != 0))
          ? Container(
              height: screenSize.size.height / 10 * 3,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Evolution des notes :",
                    style: TextStyle(color: Colors.white, fontFamily: "Asap"),
                  ),
                  Container(
                    width: screenSize.size.width / 5 * 4.2,
                    height: screenSize.size.height / 10 * 1.34,
                    child: LineChart(
                      avgData(),
                    ),
                  ),
                ],
              ),
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        MdiIcons.emoticonConfused,
                        color: Colors.white,
                      ),
                      Container(
                        margin: EdgeInsets.only(left: screenSize.size.width / 5 * 0.05),
                        child: AutoSizeText(
                          "Pas de données.",
                          style: TextStyle(fontFamily: "Asap", color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  LineChartData avgData() {
    var screenSize = MediaQuery.of(context);
    return LineChartData(
      clipData: FlClipData.horizontal(),
      backgroundColor: Colors.transparent,
      lineTouchData: LineTouchData(enabled: true),
      gridData: FlGridData(
        show: false,
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: SideTitles(showTitles: false),
        leftTitles: SideTitles(
          showTitles: true,
          getTextStyles: (value) => const TextStyle(
            color: Color(0xff67727d),
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
          getTitles: (value) {
            double max = getMax();
            double min = getMin();

            if (value == max.roundToDouble()) {
              return max.toStringAsFixed(0);
            }
            if (value == min.roundToDouble()) {
              return min.toStringAsFixed(0);
            }
            return '';
          },
          reservedSize: screenSize.size.width / 5 * 0.2,
          margin: screenSize.size.width / 5 * 0.05,
        ),
      ),
      axisTitleData: FlAxisTitleData(topTitle: AxisTitle()),
      borderData: FlBorderData(show: false, border: Border.all(color: const Color(0xff37434d), width: 1)),
      minX: 0,
      maxX: (_grades.length > 10 ? 10 : _grades.length).toDouble(),
      minY: getMin() > 0 ? getMin() - 1 : getMin(),
      maxY: getMax() + 1,
      lineBarsData: [
        LineChartBarData(
          spots: List.generate(
              _grades.length > 10 ? 10 : _grades.length, (index) => FlSpot(index.toDouble(), toDouble(_grades[index]))),
          isCurved: true,
          colors: [
            ColorTween(begin: gradientColors[0], end: gradientColors[1]).lerp(0.2),
            ColorTween(begin: gradientColors[0], end: gradientColors[1]).lerp(0.2),
          ],
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: false,
          ),
        ),
      ],
    );
  }

  List<Color> gradientColors = [
    const Color(0xff23b6e6),
    const Color(0xff02d39a),
  ];
}
