import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:graphview/GraphView.dart';
import 'package:visual_branching/util/models.dart';

class MainStatus extends ChangeNotifier {
  //opened repo, but only one repo supported now , maybe muti repo will be support
  List<Repo> openedRepoList = [];
  List<Graph> graphs = [];
  List<String> focusedNode = [];

  updateVoidCall() {
    //TODO 单个repo调用时导致全部更新（虽然目前不支持打开多个repo）
    notifyListeners();
  }

  // TODO make add list ,run notify listeners only once
  addOpenRepo(Repo item) {
    openedRepoList.add(item);
    graphs.add(Graph()..isTree = true);
    //save ref of animate ctl

    focusedNode.add(item.repoName);
    notifyListeners();
  }

  removeOpenedByKey(ValueKey targetRepoKey) {
    openedRepoList.remove(openedRepoList
        .firstWhere((element) => element.repoKey == targetRepoKey));
    //TODO 删除对应graph
    notifyListeners();
  }

  removeAllOpenedRepo() {
    openedRepoList.clear();
    graphs.clear();
    focusedNode.clear();
    notifyListeners();
  }

  focusToNode(String key) {
    focusedNode.first = key;
    notifyListeners();
  }
}
