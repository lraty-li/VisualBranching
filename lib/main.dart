import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:visual_branching/providers/main_status.dart';
import 'package:visual_branching/util/shortcut.dart';

import 'main_page.dart';

void main() {
  runApp(MultiProvider(
      providers: [
        ListenableProvider<MainStatus>(create: (context) => MainStatus())
      ],
      child: /*Shortcuts(
          //avoid “show desktop" event
          //取消，与切换输入法冲突 , 无法先于系统收起.
          shortcuts: <LogicalKeySet, Intent>{
            LogicalKeySet(LogicalKeyboardKey.metaLeft):
                const ShowDesktopIntent(),
          },
          child: Actions(
              actions: <Type, Action<Intent>>{
                ShowDesktopIntent: HideAction(),
              },
              child: const MyApp()))));*/
          const MyApp()));
  doWhenWindowReady(() {
    final win = appWindow;
    const initialSize = Size(1280, 720);
    win.minSize = const Size(640, 640);
    win.size = initialSize;
    win.alignment = Alignment.center;
    win.title = "Visual Branching";
    win.show();
  });
}
