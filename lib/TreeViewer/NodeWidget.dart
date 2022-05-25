import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:visual_branching/TreeViewer/NodeTapMenu.dart';
import 'package:visual_branching/providers/MainStatus.dart';
import 'package:visual_branching/util/funcs.dart';
import 'package:visual_branching/util/models.dart';

class NodeWidget extends StatefulWidget {
  final ValueKey<String> leafkey;
  const NodeWidget({Key? key, required ValueKey<String> this.leafkey})
      : super(key: key);

  @override
  State<NodeWidget> createState() => _NodeWidgetState();
}

class _NodeWidgetState extends State<NodeWidget> {
  //todo seleted list contains
  @override
  void initState() {
    // TODO: implement initState
    // print("nodeWidget init ${widget.data.nodeId}");
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

              //todo 简化
              if (provider.openedRepoList.first.leafs.isNotEmpty)
                Text(provider.openedRepoList.first.leafs
                    .firstWhere((element) => element.leafKey == widget.leafkey,
                        orElse: () =>
                            Leaf(const ValueKey(""), false, "no anotation"))
                    .annotation)
            ]),
          ),
        );
      },
    );
  }
}
