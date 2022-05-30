import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:graphview/GraphView.dart';
import 'package:provider/provider.dart';
import 'package:visual_branching/TreeViewer/node_widget.dart';
import 'package:visual_branching/providers/main_status.dart';
import 'package:vector_math/vector_math_64.dart' as vector_math_64;

class TreeView extends StatefulWidget {
  const TreeView({Key? key}) : super(key: key);

  @override
  State<TreeView> createState() => _TreeViewState();
}

class _TreeViewState extends State<TreeView> with TickerProviderStateMixin {
  // final Graph graph = Graph()..isTree = true;

  Node currBaseNode = Node.Id("defaultNode");
  BuchheimWalkerConfiguration builder = BuchheimWalkerConfiguration();

//ref https://github.com/nabil6391/graphview/issues/47
  final TransformationController _transformationController =
      TransformationController();
  Animation<Matrix4>? _anmation;
  late final AnimationController _animateCtl;

  @override
  void initState() {
    super.initState();

//todo  初始node id设置？
    // graph.addNode(currBaseNode);
    _animateCtl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    builder
      ..siblingSeparation = (100)
      ..levelSeparation = (150)
      ..subtreeSeparation = (150)
      ..orientation = (BuchheimWalkerConfiguration.ORIENTATION_TOP_BOTTOM);
  }

  @override
  void dispose() {
    _transformationController.dispose();
    _animateCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //重置graph
    //先添加新head

    //todo repo 与graph 对应

    var headNode =
        Node.Id(Provider.of<MainStatus>(context).openedRepoList.first.repoName);
    var graph = Provider.of<MainStatus>(context).graphs.first;
    var repo = Provider.of<MainStatus>(context).openedRepoList.first;
    var focusedNode = Provider.of<MainStatus>(context).focusedNode.first;

    graph.addNode(headNode);

    //删除旧head，
    graph.removeNode(currBaseNode);

    currBaseNode = headNode;

    if (Provider.of<MainStatus>(context).openedRepoList.isNotEmpty) {
      //添加关系
      repo.realtions.forEach((srcLeaf, desLeafs) {
        for (ValueKey dstLeaf in desLeafs) {
          graph.addEdge(Node.Id(srcLeaf.value), Node.Id(dstLeaf.value));
        }
      });

      //将根节点（roots）绑到 defaultNode
      for (var rootLeaf in repo.rootLeafKeys) {
        graph.addEdge(currBaseNode, Node.Id(rootLeaf.value));
      }
    } else {
      //todo no leaf?

    }

    //todo 去除consumer?
    return Consumer<MainStatus>(
      builder: (context, provider, child) => InteractiveViewer(
          constrained: false,
          onInteractionStart: _onInteractionStart,
          transformationController: _transformationController,
          boundaryMargin: const EdgeInsets.all(double.infinity),
          minScale: 0.1,
          maxScale: 5,
          child: GraphView(
            graph: graph,
            algorithm: _CallbackBuchheimWalkerAlgorithm(
                builder, TreeEdgeRenderer(builder), () {
              _jumpToNode(graph.getNodeUsingId(focusedNode));
            }),
            paint: Paint()
              ..color = Colors.green
              ..strokeWidth = 1
              ..style = PaintingStyle.stroke,
            builder: (Node node) {
              // var a = node.key?.value as int;
              //todo 隐患？
              //todo 直接传递string？自行生成valuekey
              return _widgetWarper(ValueKey(node.key?.value));
            },
          )),
    );
  }

  _jumpToNode(Node targetNode) {
    //todo 计算treeview 视口中心点

    final position = Offset(
      (MediaQuery.of(context).size.width / 2 -
          targetNode.x -
          targetNode.width / 2),
      ((MediaQuery.of(context).size.height - kToolbarHeight) / 2 -
          targetNode.y -
          targetNode.height / 2),
    );

    _animateDriverTo(Matrix4.compose(
        vector_math_64.Vector3(position.dx, position.dy, 0),
        vector_math_64.Quaternion(0, 0, 0, 0),
        vector_math_64.Vector3(1, 1, 1)));
  }

  void _onAnimating() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      //TODO why [_animation] will be null?
      if (_anmation != null) {
        _transformationController.value = _anmation!.value;
      }
    });

    if (!_animateCtl.isAnimating) {
      _anmation!.removeListener(_onAnimating);
      _anmation = null;
      _animateCtl.reset();
    }
  }

  void _animateDriverTo(Matrix4 endMatrix) {
    _animateCtl.reset();
    _anmation = Matrix4Tween(
      begin: _transformationController.value,
      end: endMatrix,
    ).animate(_animateCtl);
    _anmation!.addListener(_onAnimating);
    _animateCtl.forward();
  }

// Stop a running reset to home transform animation.
  void _animateStop() {
    _animateCtl.stop();
    _anmation?.removeListener(_onAnimating);
    _anmation = null;
    _animateCtl.reset();
  }

  void _onInteractionStart(ScaleStartDetails details) {
    // If the user tries to cause a transformation while the reset animation is
    // running, cancel the reset animation.
    if (_animateCtl.status == AnimationStatus.forward) {
      _animateStop();
    }
  }

  Widget _widgetWarper(ValueKey<String> leafKey) {
    return Foo(
      // index: a,
      child: NodeWidget(
        leafkey: leafKey,
      ),
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

class _CallbackBuchheimWalkerAlgorithm extends BuchheimWalkerAlgorithm {
  _CallbackBuchheimWalkerAlgorithm(
      super.configuration, super.renderer, this.sizeCalcedNotifier);
  //https://github.com/nabil6391/graphview/issues/47
  bool _wasCalculated = false;
  void Function() sizeCalcedNotifier;

  @override
  Size run(Graph? graph, double shiftX, double shiftY) {
    final size = super.run(graph, shiftX, shiftY);
    if (!_wasCalculated) {
      sizeCalcedNotifier();
      _wasCalculated = true;
    }
    return size;
  }
}
