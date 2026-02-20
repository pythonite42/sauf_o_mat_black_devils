import 'package:flutter/material.dart';
import 'package:sauf_o_mat_black_devils/theme.dart';
import 'package:sauf_o_mat_black_devils/globals.dart';
import 'package:sauf_o_mat_black_devils/page_diagram.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = WindowOptions(
    size: Size(1400, 900),
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.normal,
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });
  customDurations = CustomDurations();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sauf-O-Mat',
      theme: appTheme,
      debugShowCheckedModeBanner: false,
      home: MyScaffold(),
    );
  }
}

class MyScaffold extends StatefulWidget {
  const MyScaffold({super.key});

  @override
  State<MyScaffold> createState() => _MyScaffoldState();
}

class _MyScaffoldState extends State<MyScaffold> {
  bool titleBarVisible = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        Positioned.fill(
          child: Container(
            color: Colors.black,
            child: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/background.png"),
                    fit: BoxFit.cover,
                  ),
                ),
                child: PageDiagram()),
          ),
        ),
        Positioned(
          top: 5,
          right: 5,
          child: IconButton(
            onPressed: () async {
              if (titleBarVisible) {
                windowManager.setTitleBarStyle(TitleBarStyle.hidden);
                setState(() => titleBarVisible = false);
                await windowManager.setFullScreen(true);
              } else {
                windowManager.setTitleBarStyle(TitleBarStyle.normal);
                setState(() => titleBarVisible = true);
                await windowManager.setFullScreen(false);
              }
            },
            icon: Icon(
              titleBarVisible ? Icons.open_in_full : Icons.close_fullscreen,
              color: titleBarVisible ? Colors.grey : const Color.fromARGB(255, 67, 67, 67),
              size: GlobalSettings.fullscreenIconSize,
            ),
          ),
        ),
      ]),
    );
  }
}
