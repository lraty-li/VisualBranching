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
          Future<Leaf> newleafFuture =
              provider.openedRepoList.first.newLeaf(NodeType.manually, "新建节点");
          newleafFuture.then((newLeaf) {
            //加入graph，

            // //todo 空标头?
            provider.graphs.first.addEdge(
                provider.graphs.first.getNodeUsingId(tempOldheaderId),
                Node.Id(newLeaf.leafKey.value));

            //test
            // graph.addEdge(graph.getNodeAtPosition(graph.nodes.length - 2),
            //     graph.getNodeAtPosition(graph.nodes.length - 1));

            //todo set state？
            provider.updateVoidCall();
            // setState(() {});
          });
        },
      ),
      _styledBtn(
          text: "回退到标头",
          onTapFunc: (mainstat) {
            //todo 回退逻辑
            // repo.newLeaf(NodeType.manually, "新建节点");
          }),
    ]);
  }
}

class _styledBtn extends StatelessWidget {
  final String text;

  final void Function(MainStatus) onTapFunc;
  // _styledBtn(this.text);
  const _styledBtn(
      {Key? key,
      required this.text,
      required void Function(MainStatus) this.onTapFunc})
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
