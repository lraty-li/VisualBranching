import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:visual_branching/Repository/repository_menu.dart';
import 'package:visual_branching/providers/main_status.dart';
import 'package:visual_branching/util/funcs.dart';
import 'package:window_manager/window_manager.dart';

class WindowTitleBar extends StatelessWidget {
  final BuildContext pContext;
  const WindowTitleBar({Key? key, required this.pContext}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool nowOnTop = Provider.of<MainStatus>(context, listen: false).alwaysOnTop;
    return Row(
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
        Expanded(
          child: DragToMoveArea(
            child: Container(
              height: double.infinity,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.only(left: 16),
                    // child: DefaultTextStyle(
                    //   style: TextStyle(
                    //     color: widget.brightness == Brightness.light
                    //         ? Colors.black.withOpacity(0.8956)
                    //         : Colors.white,
                    //     fontSize: 14,
                    //   ),
                    //   child: widget.title ?? Container(),
                    // ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Builder(
          builder: (BuildContext context) {
            // bool nowOnTop =
            //     Provider.of<MainStatus>(context, listen: false).alwaysOnTop;

            return IconButton(
                icon: RotatedBox(
                    quarterTurns: nowOnTop ? 0 : 1,
                    child: nowOnTop
                        ? const Icon(Icons.push_pin_rounded)
                        : const Icon(Icons.push_pin_outlined)),
                onPressed: () {
                  nowOnTop = !nowOnTop;
                  Provider.of<MainStatus>(context, listen: false)
                      .setAlwaysOnTop(nowOnTop);
                  (context as Element).markNeedsBuild();
                });
          },
        ),
        WindowCaptionButton.minimize(
          // brightness: widget.brightness,
          onPressed: () async {
            bool isMinimized = await windowManager.isMinimized();
            if (isMinimized) {
              windowManager.restore();
            } else {
              windowManager.minimize();
            }
          },
        ),
        FutureBuilder<bool>(
          future: windowManager.isMaximized(),
          builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
            if (snapshot.data == true) {
              return WindowCaptionButton.unmaximize(
                // brightness: widget.brightness,
                onPressed: () {
                  windowManager.unmaximize();
                },
              );
            }
            return WindowCaptionButton.maximize(
              // brightness: widget.brightness,
              onPressed: () {
                windowManager.maximize();
              },
            );
          },
        ),
        WindowCaptionButton.close(
          // brightness: widget.brightness,
          onPressed: () {
            windowManager.close();
          },
        ),
      ],
    );
  }
}
