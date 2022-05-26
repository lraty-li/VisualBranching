import 'package:flutter/material.dart';
import 'package:graphview/GraphView.dart';
import 'package:provider/provider.dart';
import 'package:visual_branching/providers/MainStatus.dart';
import 'package:visual_branching/util/common.dart';
import 'package:visual_branching/util/models.dart';

class CtlBtn extends StatelessWidget {
  const CtlBtn({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      _styledBtn(
        text: "备份到标头",
        onTapFunc: (provider) async {
          final tempOldheaderId =
              "${provider.openedRepoList.first.headerLeafKey?.value}";
          Future<Leaf> newleafFuture = provider.openedRepoList.first
              .newLeaf(NodeType.manually, "新建节点", false);
          newleafFuture.then((newLeaf) {
            //加入graph，

            if (tempOldheaderId.isEmpty) {
// 当标头为空（一个节点都没有）
              provider.graphs.first.addEdge(
                  provider.graphs.first.getNodeUsingId(tempOldheaderId),
                  Node.Id(newLeaf.leafKey.value));
            } else {
              provider.graphs.first.addEdge(
                  provider.graphs.first
                      .getNodeUsingId(provider.openedRepoList.first.repoName),
                  Node.Id(newLeaf.leafKey.value));
            }

            provider.updateVoidCall();
          });
        },
      ),
      _styledBtn(
          text: "回退到标头",
          onTapFunc: (provider) {
            final tempOldheaderId =
                provider.openedRepoList.first.headerLeafKey?.value;
            if (tempOldheaderId == null) {
              // 当标头为空（一个节点都没有）

            } else {
              provider.openedRepoList.first
                  .retirveToLeaf(ValueKey(tempOldheaderId));
              provider.updateVoidCall();
            }
          }),
    ]);
  }
}

class _styledBtn extends StatelessWidget {
  final String text;

  final void Function(MainStatus) onTapFunc;
  // _styledBtn(this.text);
  const _styledBtn({Key? key, required this.text, required this.onTapFunc})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
        child: ElevatedButton(
            onPressed: () {
              onTapFunc(Provider.of<MainStatus>(context, listen: false));
            },
            child: Text(text)));
  }
}
