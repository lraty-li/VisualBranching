import 'package:flutter/material.dart';
import 'package:graphview/GraphView.dart';
import 'package:provider/provider.dart';
import 'package:visual_branching/providers/main_status.dart';
import 'package:visual_branching/util/common.dart';
import 'package:visual_branching/util/showDialogs.dart';
import 'package:visual_branching/util/models.dart';
import 'package:visual_branching/util/strings.dart';

class CtlBtn extends StatelessWidget {
  const CtlBtn({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      _StyledBtn(
        text: StringsCollection.backupToHeader,
        colorData: Colors.blue,
        onTapFunc: (provider) async {
          final tempOldheaderId =
              "${provider.openedRepoList.first.headerLeafKey?.value}";
          Future<Leaf> newleafFuture = provider.openedRepoList.first.newLeaf(
              NodeType.manually, StringsCollection.newCreatedLeaf, false);
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
            provider.focusToNode(
                provider.openedRepoList.first.headerLeafKey?.value ??
                    provider.openedRepoList.first.repoName);
          });
        },
      ),
      _StyledBtn(
          text: StringsCollection.retriveToHeader,
          colorData: Colors.blue,
          onTapFunc: (provider) {
            final tempOldheaderId =
                provider.openedRepoList.first.headerLeafKey?.value;
            if (tempOldheaderId == null) {
              // 当标头为空（一个节点都没有）

            } else {
              provider.openedRepoList.first
                  .retirveToLeaf(ValueKey(tempOldheaderId), LeafFrom.leafs);
              provider.focusToNode(tempOldheaderId);
            }
          }),
      _StyledBtn(
          text: StringsCollection.cleanRecycleBin,
          colorData: Colors.red,
          onTapFunc: (provider) {
            final result = confirmDialog(context,
                StringsCollection.clnRcyleBinConfirm, StringsCollection.clnRcyleBinAlert);
            result.then((value) {
              if (value == true) {
                provider.openedRepoList.first.clearRecycleBin();
                provider.updateVoidCall();
              }
            });
          })
    ]);
  }
}

class _StyledBtn extends StatelessWidget {
  final String text;
  final MaterialColor colorData;

  final void Function(MainStatus) onTapFunc;
  // _StyledBtn(this.text);
  const _StyledBtn(
      {Key? key,
      required this.text,
      required this.onTapFunc,
      required this.colorData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
        child: ElevatedButton(
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(colorData)),
            onPressed: () {
              onTapFunc(Provider.of<MainStatus>(context, listen: false));
            },
            child: Text(text)));
  }
}
