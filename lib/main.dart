import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
import 'package:window_manager/window_manager.dart';
// import 'package:visual_branching/util/shortcut.dart';

import 'main_page.dart';

Future<void> main() async {
  /*Shortcuts(
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

  WidgetsFlutterBinding.ensureInitialized();
  // 必须加上这一行。
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    size: Size(800, 600),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(const MyApp());
}
