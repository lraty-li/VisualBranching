import 'package:flutter/cupertino.dart';

class RepoConfig extends ChangeNotifier {
  late String repoName;
  late bool autoSave;
  late int autoSaveInterval;
  late int autoSavesNums;
  late List<String> targetFilePaths = [];
  bool validated = false;

  _validate() {
    if (repoName.length != 0 && targetFilePaths.length != 0)
      validated = true;
    else {
      validated = false;
    }
  }

  addTarget(String path) {
    targetFilePaths.add(path);
    _validate();
    notifyListeners();
  }

  delTarget(int index) {
    targetFilePaths.removeAt(index);
    _validate();
    notifyListeners();
  }

  clearAllTarget() {
    targetFilePaths.clear();
    _validate();
    notifyListeners();
  }

  setRepoName(String newRepoName) {
    repoName = newRepoName;
    _validate();
    notifyListeners();
  }

  RepoConfig({
    this.repoName = "",
    this.autoSave = false,
    this.autoSaveInterval = -1,
    this.autoSavesNums = -1,
  });
}
