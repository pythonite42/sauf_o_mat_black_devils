import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sauf_o_mat_black_devils/backend_connection.dart';
import 'package:sauf_o_mat_black_devils/theme.dart';
import 'package:sauf_o_mat_black_devils/globals.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:math';
import 'package:google_fonts/google_fonts.dart';

class ChartData {
  ChartData({
    this.group,
    this.shot,
    this.status,
    this.color,
  });

  final String? group;
  final int? shot;
  final String? status;
  final Color? color;
}

class PageDiagram extends StatefulWidget {
  const PageDiagram({super.key});

  @override
  State<PageDiagram> createState() => _PageDiagramState();
}

class _PageDiagramState extends State<PageDiagram> {
  final ScrollController _scrollController = ScrollController();
  List<ChartData>? _chartData = [];
  late Timer _scrollTimer;
  late Timer _chartDataReloadTimer;
  double barHeight = 0;
  int? maxValue;

  Color fontColor = Colors.white;

  @override
  void initState() {
    super.initState();

    _loadChartData();
    _startAutoReloadChartData();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAutoScroll();
    });
  }

  void _startAutoReloadChartData() {
    _chartDataReloadTimer = Timer.periodic(Duration(seconds: customDurations.reloadDataDiagram), (_) {
      _loadChartData();
    });
  }

  Future<void> _loadChartData() async {
    try {
      List<Map> newDataMapList = await SalesforceService().getPageDiagram();

      List<ChartData> newData = [];
      for (var newDataMap in newDataMapList) {
        newData.add(
          ChartData(
            group: newDataMap["group"],
            color: Color(int.parse(newDataMap["color"].substring(1), radix: 16) + 0xFF000000),
            shot: newDataMap["shot"],
            status: newDataMap["status"],
          ),
        );
      }
      if (mounted) {
        setState(() {
          _chartData = newData;
          _chartData?.sort((a, b) {
            return (b.shot ?? 0).compareTo(a.shot ?? 0);
          });
          maxValue = _chartData?[0].shot ?? 0 + 50;
        });
      }
    } catch (e) {
      debugPrint('Error fetching chart data: $e');
    }
  }

  void _startAutoScroll() {
    var duration = Duration(seconds: customDurations.chartAutoScroll);

    _scrollTimer = Timer.periodic(duration, (timer) {
      if (!_scrollController.hasClients) return;

      final maxScroll = _scrollController.position.maxScrollExtent;
      final current = _scrollController.offset;
      final next = current + barHeight;

      _scrollController.animateTo(
        next >= (maxScroll + barHeight / 2) ? 0 : next,
        duration: Duration(milliseconds: customDurations.speedChartScroll),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _chartDataReloadTimer.cancel();
    _scrollTimer.cancel();
    _scrollController.dispose();

    super.dispose();
  }

  double getBarHeight(double screenHeight) {
    return screenHeight / 8;
  }

  @override
  Widget build(BuildContext context) {
    final fontSizeLegend = 30.0;

    return Stack(
      children: [
        Padding(
          padding: EdgeInsetsGeometry.symmetric(
            vertical: MySize(context).h * 0.05,
            horizontal: MySize(context).w * 0.03,
          ),
          child: Column(children: [
            Text("Sauf - O - Mat",
                style: GoogleFonts.unifrakturCook(
                    fontSize: fontSizeLegend * 3, fontWeight: FontWeight.bold, color: fontColor)),
            Expanded(
              child: Padding(
                padding: EdgeInsetsGeometry.only(
                  top: MySize(context).h * 0.05,
                  right: MySize(context).w * 0.05,
                ),
                child: (_chartData == null || _chartData!.isEmpty)
                    ? Center(
                        child: CircularProgressIndicator(color: fontColor),
                      )
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          var textStyle = TextStyle(fontSize: 30, color: fontColor, fontWeight: FontWeight.bold);
                          var textPainter = TextPainter(
                              text: TextSpan(text: "20", style: textStyle),
                              maxLines: 1,
                              //textScaler: TextScaler.linear(MediaQuery.of(context).textScaleFactor),
                              textDirection: TextDirection.ltr);
                          final Size size = (textPainter..layout()).size;

                          final availableHeight = constraints.maxHeight - size.height;
                          barHeight = (availableHeight / GlobalSettings.totalBarsVisible);
                          double frameLineWidth = 4;
                          var groupNameWidth = constraints.maxWidth * GlobalSettings.groupNameSpaceFactor;
                          var chartWidth = constraints.maxWidth - groupNameWidth;
                          var gridLine = Container(width: chartWidth, height: 1, color: fontColor);

                          int gridIntervalsDividableBy = 10;
                          int emptyCountRightOfFirst = 10;
                          if ((maxValue ?? 1) < 50) {
                            gridIntervalsDividableBy = 5;
                            emptyCountRightOfFirst = 3;
                          }

                          int chartMaxValue = maxValue ?? 1 + emptyCountRightOfFirst;

                          while (true) {
                            if ((chartMaxValue / GlobalSettings.totalGridLinesVisible) % gridIntervalsDividableBy ==
                                0) {
                              break;
                            } else {
                              chartMaxValue++;
                            }
                          }

                          var gridInterval = chartMaxValue / GlobalSettings.totalGridLinesVisible;

                          return Stack(
                            children: <Widget>[
                              Positioned(
                                  left: groupNameWidth,
                                  child: Container(width: frameLineWidth, height: availableHeight, color: fontColor)),
                              /* Positioned(
                                left: groupNameWidth,
                                child: Container(width: chartWidth, height: frameLineWidth, color: fontColor)), */
                              /* Positioned(
                                left: groupNameWidth + chartWidth - frameLineWidth,
                                child:
                                    Container(width: frameLineWidth, height: availableHeight, color: fontColor)), */
                              Positioned(
                                  left: groupNameWidth,
                                  top: availableHeight - frameLineWidth,
                                  child: Container(width: chartWidth, height: frameLineWidth, color: fontColor)),
                              // Horizontal grid lines (exclude the topmost line)
                              ...List.generate(
                                (GlobalSettings.totalGridLinesVisible).floor(),
                                (index) => Positioned(
                                  left: groupNameWidth,
                                  top: (index + 1) * (availableHeight / GlobalSettings.totalGridLinesVisible),
                                  child: gridLine,
                                ),
                              ),

                              // Numeric labels along the bottom (x-axis)
                              ...List.generate(
                                (GlobalSettings.totalGridLinesVisible).floor(),
                                (index) => Positioned(
                                  left: groupNameWidth +
                                      (index + 1) * (chartWidth / GlobalSettings.totalGridLinesVisible),
                                  top: availableHeight,
                                  child: Text(
                                    ((index + 1) * gridInterval).toInt().toString(),
                                    style: textStyle,
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: availableHeight,
                                child: ScrollConfiguration(
                                  behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                                  child: ListView.builder(
                                    physics: const NeverScrollableScrollPhysics(),
                                    controller: _scrollController,
                                    itemCount: _chartData?.length,
                                    itemBuilder: (context, index) {
                                      final data = _chartData?[index];

                                      return SizedBox(
                                        height: barHeight,
                                        child: Row(
                                          children: [
                                            Container(
                                              width: groupNameWidth,
                                              padding: EdgeInsets.only(right: 20),
                                              child: Row(
                                                children: [
                                                  data?.status == "Aufgestiegen"
                                                      ? SvgPicture.asset(
                                                          'assets/arrow_up.svg',
                                                          width: fontSizeLegend,
                                                          height: fontSizeLegend,
                                                          colorFilter: ColorFilter.mode(greenAccent, BlendMode.srcIn),
                                                        )
                                                      : data?.status == "Abgestiegen"
                                                          ? Transform.rotate(
                                                              angle: pi,
                                                              child: SvgPicture.asset(
                                                                'assets/arrow_up.svg',
                                                                width: fontSizeLegend,
                                                                height: fontSizeLegend,
                                                                colorFilter:
                                                                    ColorFilter.mode(redAccent, BlendMode.srcIn),
                                                              ),
                                                            )
                                                          : SvgPicture.asset(
                                                              'assets/arrow_up.svg',
                                                              width: fontSizeLegend,
                                                              height: fontSizeLegend,
                                                              colorFilter:
                                                                  ColorFilter.mode(Colors.transparent, BlendMode.srcIn),
                                                            ),
                                                  Text(
                                                    data?.group != null ? "  ${index + 1}.  " : '',
                                                    style: TextStyle(
                                                      fontSize: fontSizeLegend,
                                                      fontWeight: FontWeight.bold,
                                                      color: fontColor,
                                                    ),
                                                  ),
                                                  Flexible(
                                                    child: Text(
                                                      data?.group != null ? "${data?.group}" : '',
                                                      style: TextStyle(
                                                          fontSize: fontSizeLegend,
                                                          fontWeight: FontWeight.bold,
                                                          color: fontColor,
                                                          height: 1),
                                                      softWrap: true,
                                                      overflow: TextOverflow.ellipsis,
                                                      maxLines: 2,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Expanded(
                                              child: LayoutBuilder(
                                                builder: (context, constraints) {
                                                  final totalWidth = constraints.maxWidth;
                                                  final shot = (data?.shot ?? 0).toDouble();

                                                  // Avoid division by zero
                                                  if (chartMaxValue == 0) return const SizedBox();

                                                  return Padding(
                                                      padding: EdgeInsetsGeometry.symmetric(
                                                          vertical: constraints.maxHeight * 0.15),
                                                      child: Stack(
                                                        children: [
                                                          Row(children: [
                                                            Stack(children: [
                                                            Container(
                                                              height: constraints.maxHeight * 0.5,
                                                              width: totalWidth * shot / chartMaxValue,
                                                              decoration: BoxDecoration(
                                                                color: data!.color!.withValues(alpha: 0.9),
                                                                borderRadius: BorderRadius.horizontal(
                                                                    right:
                                                                        Radius.circular(constraints.maxHeight * 0.08),
                                                                ),
                                                                boxShadow: [
                                                                  BoxShadow(
                                                                    color: Colors.black,
                                                                    blurRadius: 8,
                                                                    offset: Offset(0, 4),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                              Text(
                                                                ' ${shot.toStringAsFixed(0)} Shots',
                                                                style: TextStyle(
                                                                  fontSize: fontSizeLegend,
                                                                  fontWeight: FontWeight.bold,
                                                                  color: fontColor,
                                                                ),
                                                              ),
                                                            ]),
                                                            Visibility(
                                                              visible: false,
                                                              maintainSize: true,
                                                              maintainAnimation: true,
                                                              maintainState: true,
                                                              child: Transform.scale(
                                                                scale: 5,
                                                                child: Image.asset(
                                                                  'assets/flame.png',
                                                                ),
                                                              ),
                                                            ),
                                                          ]),
                                                          Container(
                                                            height: double.infinity,
                                                            width: frameLineWidth,
                                                            color: fontColor,
                                                          )
                                                        ],
                                                      ));
                                                },
                                              ),
                                            )
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
              ),
            ),
          ]),
        )
      ],
    );
  }
}

class FlameOverlay extends StatefulWidget {
  const FlameOverlay({super.key, this.scale = 1.0});

  final double scale;

  @override
  State<FlameOverlay> createState() => _FlameOverlayState();
}

class _FlameOverlayState extends State<FlameOverlay> with SingleTickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double s = widget.scale;
    final double baseOffset = 4.0;
    final double baseMove = 6.0;
    final double baseWidth = 22.0;
    final double baseHeight = 32.0;
    final double baseIcon = 28.0;
    final double baseBlur1 = 12.0;
    final double baseBlur1Add = 8.0;
    final double baseSpread = 2.0;
    final double baseBlur2 = 20.0;

    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        return Transform.translate(
          offset: Offset((baseOffset + controller.value * baseMove) * s, 0),
          child: Container(
              width: baseWidth * s,
              height: baseHeight * s,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.8),
                    blurRadius: baseBlur1 + controller.value * baseBlur1Add * s,
                    spreadRadius: baseSpread * s,
                  ),
                  BoxShadow(
                    color: Colors.red.withOpacity(0.6),
                    blurRadius: baseBlur2 * s,
                  ),
                ],
              ),
              child: Image.asset("assets/flame.png", width: baseIcon * s, height: baseIcon * s)),
        );
      },
    );
  }
}
