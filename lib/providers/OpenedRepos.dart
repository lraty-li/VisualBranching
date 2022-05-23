import 'package:flutter/widgets.dart';
import 'package:visual_branching/util/models.dart';

class OpenedRepos extends ChangeNotifier {
  //opened repo, but only one repo supported now , maybe muti repo will be support
  List<Repo> openedRepoList = [];


  /// todo make add list ,run notify listeners only once
  void add(Repo item) {
    openedRepoList.add(item);
    notifyListeners();
  }

  removeByKey(ValueKey targetRepoKey) {
    openedRepoList.remove(openedRepoList
        .firstWhere((element) => element.repoKey == targetRepoKey));
    notifyListeners();
  }

  void removeAll() {
    openedRepoList.clear();
    notifyListeners();
  }
}
