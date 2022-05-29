import 'package:flutter/cupertino.dart';

class RepoConfig extends ChangeNotifier {
  late String repoName;
  late bool autoSave;
  late int autoSaveInterval;
  late int autoSavesNums;
  late List<String> targetFilePaths;
  bool validated = false;

  _validate() {
    if (repoName.isNotEmpty && targetFilePaths.isNotEmpty) {
      if (autoSave) {
        if (autoSavesNums > 0 && autoSaveInterval > 0) {
          validated = true;
        } else {
          validated = false;
        }
      } else {
        validated = true;
      }
    } else {
      validated = false;
    }

    notifyListeners();
  }

  addTarget(String path) {
    targetFilePaths.add(path);
    _validate();
  }

  delTarget(int index) {
    targetFilePaths.removeAt(index);
    _validate();
  }

  clearAllTarget() {
    targetFilePaths.clear();
    _validate();
  }


  setRepoName(String newRepoName) {
    repoName = newRepoName;
    _validate();
  }

  setIfAutoSave(bool value) {
    autoSave = value;
    _validate();
  }
  setAutoSaveIntervel(int value) {
    autoSaveInterval=value;
    _validate();
  }

  setAutoSaveNums(int value) {
    autoSavesNums=value;
    _validate();
  }

  static fromConfig(RepoConfig oldConfig) {
    return RepoConfig(
        repoName: oldConfig.repoName,
        autoSave: oldConfig.autoSave,
        autoSaveInterval: oldConfig.autoSaveInterval,
        autoSavesNums: oldConfig.autoSavesNums,
        targetFilePaths: []);
  }

  RepoConfig({
    this.repoName = "",
    this.autoSave = false,
    this.autoSaveInterval = -1,
    this.autoSavesNums = -1,
    required this.targetFilePaths,
  });
}
