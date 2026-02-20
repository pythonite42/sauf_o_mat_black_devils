import 'package:flutter/material.dart';

class MySize {
  double h = 0.0; //height
  double w = 0.0; //width
  BuildContext context;

  MySize(this.context) {
    w = MediaQuery.of(context).size.width;
    h = MediaQuery.of(context).size.height - GlobalSettings.fullscreenIconSize;
  }
}

late final dynamic customDurations;

class CustomDurations {
  // ##### frontend ######################

  final int reloadDataDiagram = 7;
  final int chartAutoScroll = 8; //every x seconds the chart scrolls one bar down
  final int speedChartScroll = 500;

  // ##### salesforce ######################

  final int diagramStatusAufgestiegenAbgestiegen = 20; //seconds a group is marked as "aufgestiegen" or "abgestiegen"
}

class GlobalSettings {
  static const double fullscreenIconSize = 20;

  // page diagram
  static const int totalBarsVisible = 5;
  static const int axisNumbers = 4;
  static const double groupNameSpaceFactor = 0.37; //Anteilig an ganzer Breite
}
