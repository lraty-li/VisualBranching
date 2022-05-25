import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:visual_branching/providers/MainStatus.dart';
import 'package:visual_branching/util/common.dart';
import 'dart:io';

void nodeOnTap(BuildContext context, ValueKey<String> nodeKey) {
  if (!Provider.of<MainStatus>(context, listen: false)
      .openedRepoList
      .first
      .leafs
      .any(
        (element) => element.leafKey == nodeKey,
      )) {
    //点击了头节点，不显示菜单
    return;
  }
  showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: Text("选择"),
          children: [
            SimpleDialogOption(
                child: Text("回档到该节点"),
                onPressed: (() {
                  Provider.of<MainStatus>(context, listen: false)
                      .openedRepoList
                      .first
                      .retirveToLeaf(nodeKey);
                  Provider.of<MainStatus>(context, listen: false)
                      .updateVoidCall();

                  Navigator.of(context).pop();
                })),
            // SimpleDialogOption(
            //     child: Text("设为标头"), onPressed: (() => {print("Line35")})),
            SimpleDialogOption(
                child: Text("由节点新建分支"),
                onPressed: (() {
                  // 复制节点信息
                  final targetLeaf =
                      Provider.of<MainStatus>(context, listen: false)
                          .openedRepoList
                          .first
                          .leafs
                          .firstWhere((element) => element.leafKey == nodeKey);
                  Provider.of<MainStatus>(context, listen: false)
                      .openedRepoList
                      .first
                      .newLeaf(NodeType.manually, targetLeaf.annotation, true);

                  Provider.of<MainStatus>(context, listen: false)
                      .updateVoidCall();

                  Navigator.of(context).pop();
                })),
            SimpleDialogOption(
                child: Text("打开节点文件路径"),
                onPressed: (() async {
                  final path = Uri.file(
                      Provider.of<MainStatus>(context, listen: false)
                              .openedRepoList
                              .first
                              .repoPath +
                          Platform.pathSeparator +
                          nodeKey.value,
                      windows: true);
                  //todo 出错控制
                  if (!await launchUrl(path)) throw 'Could not launch $path';
                })),
            SimpleDialogOption(
                child: Text("删除该节点"),
                onPressed: (() {
                  Provider.of<MainStatus>(context, listen: false)
                      .openedRepoList
                      .first
                      .delLeaf(nodeKey);
                  Provider.of<MainStatus>(context, listen: false)
                      .updateVoidCall();
                  Navigator.of(context).pop();
                })),
          ],
        );
      });
}
