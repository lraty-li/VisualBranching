import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:provider/provider.dart';
import 'package:visual_branching/providers/OpenedRepos.dart';

import 'mainPage.dart';

void main() {
  runApp(MultiProvider(
      providers: [ListenableProvider<OpenedRepos>(create: (context) => OpenedRepos())],
      child: const MyApp()));
  doWhenWindowReady(() {
    final win = appWindow;
    const initialSize = Size(1280, 720);
    win.minSize = Size(640, 640);
    win.size = initialSize;
    win.alignment = Alignment.center;
    win.title = "Custom window with Flutter";
    win.show();
  });
}
