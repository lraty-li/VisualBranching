import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:graphview/GraphView.dart';
import 'package:provider/provider.dart';
import 'package:visual_branching/Repository/OepnRepo.dart';
import 'package:visual_branching/TreeViewer/dataClass.dart';
import 'package:visual_branching/providers/OpenedRepos.dart';
import 'package:visual_branching/util/models.dart';

import 'NodeWidget.dart';

class TreeView extends StatefulWidget {
  const TreeView({Key? key}) : super(key: key);

  @override
  State<TreeView> createState() => _TreeViewState();
}

class _TreeViewState extends State<TreeView> {
  final Graph graph = Graph()..isTree = true;

  Node currBaseNode = Node.Id("defaultNode");
  BuchheimWalkerConfiguration builder = BuchheimWalkerConfiguration();

  @override
  void initState() {
    super.initState();

//todo  初始node id设置？
    graph.addNode(currBaseNode);

    builder
      ..siblingSeparation = (100)
      ..levelSeparation = (150)
      ..subtreeSeparation = (150)
      ..orientation = (BuchheimWalkerConfiguration.ORIENTATION_TOP_BOTTOM);
  }

  Widget _WidgetWarper(ValueKey<String> leafKey) {
    return Foo(
      // index: a,
      child: NodeWidget(
        leafkey: leafKey,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    //todo 重置graph
    //先添加新head

    var headNode = Node.Id(
        Provider.of<OpenedRepos>(context).openedRepoList.first.repoName);
    graph.addNode(headNode);
    
    //删除旧head，
    graph.removeNode(currBaseNode);

    currBaseNode=headNode;

    if (Provider.of<OpenedRepos>(context).openedRepoList.isNotEmpty) {
      //添加关系
      Provider.of<OpenedRepos>(context)
          .openedRepoList
          .first
          .realtions
          .forEach((srcLeaf, desLeafs) {
        for (ValueKey dstLeaf in desLeafs) {
          graph.addEdge(Node.Id(srcLeaf.value), Node.Id(dstLeaf.value));
        }
      });

      //将根节点（roots）绑到 defaultNode
      Provider.of<OpenedRepos>(context)
          .openedRepoList
          .first
          .rootLeafKeys
          .forEach((rootLeaf) {
        graph.addEdge(currBaseNode, Node.Id(rootLeaf.value));
      });
    } else {
      //todo no leaf?

    }

    print("line64 hi");
    //todo 去除consumer
    return Consumer<OpenedRepos>(
      builder: (context, provider, child) => InteractiveViewer(
          constrained: false,
          boundaryMargin: EdgeInsets.all(double.infinity),
          minScale: 0.001,
          maxScale: 50,
          child: GraphView(
            graph: graph,
            algorithm:
                BuchheimWalkerAlgorithm(builder, TreeEdgeRenderer(builder)),
            paint: Paint()
              ..color = Colors.green
              ..strokeWidth = 1
              ..style = PaintingStyle.stroke,
            builder: (Node node) {
              // var a = node.key?.value as int;
              //todo 隐患？
              //todo 直接传递string？自行生成valuekey
              return _WidgetWarper(ValueKey(node.key?.value));
            },
          )),
    );
  }
}

class Foo extends SingleChildRenderObjectWidget {
  // final int index;

  // const Foo({Widget? child, required this.index, Key? key})
  const Foo({Widget? child, Key? key}) : super(child: child, key: key);

  @override
  _Foo createRenderObject(BuildContext context) {
    // return _Foo()..index = index;
    return _Foo();
  }

  @override
  void updateRenderObject(BuildContext context, _Foo renderObject) {
    // renderObject..index = index;
  }
}

class _Foo extends RenderProxyBox {
  // late int index;
}
