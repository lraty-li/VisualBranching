import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:visual_branching/MainUi/SideListView.dart';
import 'package:visual_branching/TreeViewer/View.dart';
import 'package:visual_branching/providers/MainStatus.dart';
import 'MainUi/CtlBtn.dart';
import 'MainUi/WindowTitleBar.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:visual_branching/Repository/RepositoryMenu.dart';

const borderColor = Color(0xFF805306);

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: HomePage(),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        WindowTitleBar(
          pContext: context,
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height - appWindow.titleBarHeight,
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
    );
  }
}

Widget _fakeTreeWindow() {
  //when no repo opened
  return Flex(
    direction: Axis.horizontal,
    children: [
      //未开启任何repo时

      //todo 点击打开repo？
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
