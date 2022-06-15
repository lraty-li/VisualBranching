import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:visual_branching/providers/main_status.dart';
import 'package:visual_branching/util/common.dart';

import 'package:visual_branching/util/showDialogs.dart';
import 'package:visual_branching/util/strings.dart';

void nodeOnTap(BuildContext context, ValueKey<String> nodeKey) {
  final targetRepo =
      Provider.of<MainStatus>(context, listen: false).openedRepoList.first;
  final provider = Provider.of<MainStatus>(context, listen: false);
  //the repoIdName node, not in repo.leafs
  //TODO 优化检测头节点点击
  var isBase = true;
  String nodeAnno = "";
  for (var leaf in targetRepo.leafs) {
    if (leaf.leafKey == nodeKey) {
      isBase = false;
      nodeAnno = leaf.annotation;
    }
  }
  if (isBase) {
    //点击了头节点，不显示菜单
    return;
  }
  showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: Text(nodeAnno),
          //TODO 改为builders.dart ,根据枚举生成选项
          children: [
            SimpleDialogOption(
              onPressed: (() {
                targetRepo.retirveToLeaf(nodeKey, LeafFrom.leafs);
                provider

                    //todo 已有nodeKey
                    .focusToNode(nodeKey.value);

                Navigator.of(context).pop();
              }),
              child: const Text(StringsCollection.retriveToLeaf),
            ),
            // SimpleDialogOption(
            //     child: Text("设为标头"), onPressed: (() => {print("Line35")})),
            SimpleDialogOption(
              onPressed: (() {
                // 复制节点信息

                final targetLeaf = targetRepo.leafs
                    .firstWhere((element) => element.leafKey == nodeKey);
                targetRepo
                    .newLeaf(NodeType.manually, targetLeaf.annotation, true)
                    .then((newLeaf) {
                  provider.focusToNode(newLeaf.leafKey.value);
                });

                Navigator.of(context).pop();
              }),
              child: const Text(StringsCollection.newBranchFromLeaf),
            ),
            SimpleDialogOption(
              onPressed: (() async {
                final path = Uri.file(
                    targetRepo.genLeafPath(nodeKey, LeafFrom.leafs),
                    windows: true);
                //todo 出错控制
                if (!await launchUrl(path)) throw 'Could not launch $path';
              }),
              child: const Text(StringsCollection.openLeafDir),
            ),
            SimpleDialogOption(
              onPressed: (() async {
                final navigator = Navigator.of(context);
                String? newAnnotation =
                    await strDialog(context, StringsCollection.alterAnnotation,StringsCollection.inputNewAnnoation);
                targetRepo.alterLeafAnno(nodeKey, newAnnotation ?? "");
                provider.focusedNode.first = nodeKey.value;
                provider.updateVoidCall();

                navigator.pop();
              }),
              child: const Text(StringsCollection.alterAnnotation),
            ),
            SimpleDialogOption(
              onPressed: (() {
                final parentLeaf = targetRepo.getParentLeaf(nodeKey);
                targetRepo.delLeaf(nodeKey);
                //聚焦到被删节点父节点而不是标头，避免当删除远处节点时聚焦到标头
                provider.focusToNode(parentLeaf == null
                    ? targetRepo.repoName
                    : parentLeaf.value);
                Navigator.of(context).pop();
              }),
              child: const Text(StringsCollection.delLeaf),
            ),
          ],
        );
      });
}
