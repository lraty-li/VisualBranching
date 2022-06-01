import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:visual_branching/Repository/repository_menu.dart';
import 'package:visual_branching/util/funcs.dart';

class WindowTitleBar extends StatelessWidget {
  final BuildContext pContext;
  const WindowTitleBar({Key? key, required this.pContext}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WindowTitleBarBox(
      child: Row(
        children: [
          repoMenuBuilder(pContext),
          ElevatedButton(
              onPressed: () => {
                    confirmDialog(context, "设置",
                            "这是未完成版本,你可以点击确认前往github页面寻找更新\nhttps://github.com/lraty-li/VisualBranching")
                        .then((confirmed) {
                      if (confirmed == true) {
                        launchUrl(Uri.parse(
                            "https://github.com/lraty-li/VisualBranching"));
                      }
                    })
                  },
              child: const Text("软件设置")),
          Expanded(child: MoveWindow()),
          const WindowButtons()
        ],
      ),
    );
  }
}

final buttonColors = WindowButtonColors(
    iconNormal: const Color(0xFF000000),
    mouseOver: const Color(0xFF2196F3),
    mouseDown: const Color(0xFF88C7F9),
    iconMouseOver: const Color(0xFFFFFFFF),
    iconMouseDown: const Color(0xFF007ACC));

final closeButtonColors = WindowButtonColors(
    iconNormal: const Color(0xFF000000),
    mouseOver: const Color(0xFFD32F2F),
    mouseDown: const Color(0xFFB71C1C),
    iconMouseOver: Colors.white);

class WindowButtons extends StatelessWidget {
  const WindowButtons({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        MinimizeWindowButton(colors: buttonColors),
        MaximizeWindowButton(colors: buttonColors),
        CloseWindowButton(colors: closeButtonColors),
      ],
    );
  }
}
