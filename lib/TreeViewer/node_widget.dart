import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:visual_branching/TreeViewer/node_tap_menu.dart';
import 'package:visual_branching/providers/main_status.dart';
import 'package:visual_branching/util/models.dart';

//todo 改位staless？
class NodeWidget extends StatefulWidget {
  final ValueKey<String> leafkey;
  const NodeWidget({Key? key, required this.leafkey}) : super(key: key);

  @override
  State<NodeWidget> createState() => _NodeWidgetState();
}

class _NodeWidgetState extends State<NodeWidget> {
  //todo seleted list contains
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MainStatus>(
      builder: (context, provider, child) {
        return InkWell(
          // hoverColor: Colors.red,
          onLongPress: () async {
            // String? str =
            //     await strDialog(context, "修改备注", widget.data.annotation);

            // if (str != null) {
            //   setState(() {
            //     widget.data.annotation = str;
            //   });
            // }
          },
          onTap: () async {
            nodeOnTap(context, widget.leafkey);
          },
          //todo hover detail
          // onHover: (hovering) => {print("LINE 14 NodeWidget.dart")},
          child: Container(
            decoration: BoxDecoration(
                color: Provider.of<MainStatus>(context)
                            .openedRepoList
                            .first
                            .headerLeafKey ==
                        widget.leafkey
                    ? Colors.blueAccent
                    : Colors.transparent),
            child: Wrap(direction: Axis.vertical, children: [
              Text(
                widget.leafkey.value,
              ),

              //todo repoName 节点的信息冗余（去掉orElse？
              Text(provider.openedRepoList.first.leafs
                  .firstWhere((element) => element.leafKey == widget.leafkey,
                      orElse: () => Leaf(const ValueKey(""), ""))
                  .createdTime
                  .toString()),
              //当创建repo 名字的node时，会转入orElse ,显示repo名称
              Text(provider.openedRepoList.first.leafs
                  .firstWhere((element) => element.leafKey == widget.leafkey,
                      orElse: () => Leaf(const ValueKey(""), widget.leafkey.value))
                  .annotation)
            ]),
          ),
        );
      },
    );
  }
}
