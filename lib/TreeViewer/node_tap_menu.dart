import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:visual_branching/providers/main_status.dart';
import 'package:visual_branching/util/common.dart';

import 'package:visual_branching/util/funcs.dart';

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
          title: Text(nodeKey.value),
          children: [
            SimpleDialogOption(
              onPressed: (() {
                Provider.of<MainStatus>(context, listen: false)
                    .openedRepoList
                    .first
                    .retirveToLeaf(nodeKey, LeafFrom.leafs);
                Provider.of<MainStatus>(context, listen: false)

                    //todo 已有nodeKey
                    .focusToNode(nodeKey.value);

                Navigator.of(context).pop();
              }),
              child: const Text("回档到该节点"),
            ),
            // SimpleDialogOption(
            //     child: Text("设为标头"), onPressed: (() => {print("Line35")})),
            SimpleDialogOption(
              onPressed: (() {
                // 复制节点信息
                final provider =
                    Provider.of<MainStatus>(context, listen: false);
                final repo = provider.openedRepoList.first;
                final targetLeaf = repo.leafs
                    .firstWhere((element) => element.leafKey == nodeKey);
                repo
                    .newLeaf(NodeType.manually, targetLeaf.annotation, true)
                    .then((newLeaf) {
                  provider.focusToNode(newLeaf.leafKey.value);
                });

                Navigator.of(context).pop();
              }),
              child: const Text("由节点新建分支"),
            ),
            SimpleDialogOption(
              onPressed: (() async {
                final path = Uri.file(
                    Provider.of<MainStatus>(context, listen: false)
                        .openedRepoList
                        .first
                        .genLeafPath(nodeKey, LeafFrom.leafs),
                    windows: true);
                //todo 出错控制
                if (!await launchUrl(path)) throw 'Could not launch $path';
              }),
              child: const Text("打开节点文件路径"),
            ),
            SimpleDialogOption(
              onPressed: (() async {
                final provider =
                    Provider.of<MainStatus>(context, listen: false);
                final navigator = Navigator.of(context);
                String? newAnnotation =
                    await strDialog(context, "修改备注", "输入新备注");
                provider.openedRepoList.first
                    .alterLeafAnno(nodeKey, newAnnotation ?? "");

                provider.updateVoidCall();

                navigator.pop();
              }),
              child: const Text("修改备注"),
            ),
            SimpleDialogOption(
              onPressed: (() {
                final provider =
                    Provider.of<MainStatus>(context, listen: false);
                final repo = provider.openedRepoList.first;
                final parentLeaf = repo.getParentLeaf(nodeKey);
                repo.delLeaf(nodeKey);
                //聚焦到被删节点父节点而不是标头，避免当删除远处节点时聚焦到标头
                provider.focusToNode(
                    parentLeaf == null ? repo.repoName : parentLeaf.value);
                Navigator.of(context).pop();
              }),
              child: const Text("删除该节点"),
            ),
          ],
        );
      });
}
