import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:visual_branching/MainUi/side_list_view.dart';
import 'package:visual_branching/TreeViewer/view.dart';
import 'package:visual_branching/providers/main_status.dart';
import 'package:window_manager/window_manager.dart';
import 'MainUi/ctl_btn.dart';
import 'MainUi/window_title_bar.dart';

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final virtualWindowFrameBuilder = VirtualWindowFrameInit();
    final botToastBuilder = BotToastInit();

    return MultiProvider(
        providers: [
          ListenableProvider<MainStatus>(create: (context) => MainStatus())
        ],
        child: MaterialApp(
            debugShowCheckedModeBanner: false,
            builder: (context, child) {
              child = virtualWindowFrameBuilder(context, child);
              child = botToastBuilder(context, child);
              return child;
            },
            navigatorObservers: [BotToastNavigatorObserver()],
            home: const HomePage()));
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: WindowTitleBar(
          pContext: context,
        ),
      ),
      body: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height -
                kToolbarHeight /* - windowManager.getTitleBarHeight()*/,
            width: MediaQuery.of(context).size.width,
            child: Consumer<MainStatus>(
              builder: (context, provider, child) =>
                  provider.openedRepoList.isEmpty
                      //未开启任何repo时
                      ? _fakeTreeWindow()
                      : Flex(
                          direction: Axis.horizontal,
                          children: [
                            const Expanded(flex: 5, child: TreeView()),
                            Expanded(
                                flex: 1,
                                child: Flex(
                                  direction: Axis.vertical,
                                  children: const [
                                    Expanded(child: SideListView()),
                                    CtlBtn()
                                  ],
                                ))
                          ],
                        ),
            ),
          )
        ],
      ),
    );
  }
}

Widget _fakeTreeWindow() {
  //when no repo opened
  return Flex(
    direction: Axis.horizontal,
    children: [
      //未开启任何repo时

      Expanded(flex: 5, child: Container()),
      Expanded(
          flex: 1,
          child: Flex(
            direction: Axis.vertical,
            children: [Expanded(child: Container()), Container()],
          ))
    ],
  );
}
