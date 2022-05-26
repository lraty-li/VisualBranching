import 'package:flutter/cupertino.dart';

class RepoConfig extends ChangeNotifier {
  late String repoName;
  late bool autoSave;
  late int autoSaveInterval;
  late int autoSavesNums;
  late List<String> targetFilePaths;
  bool validated = false;

  validate() {
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
    validate();
  }

  delTarget(int index) {
    targetFilePaths.removeAt(index);
    validate();
  }

  clearAllTarget() {
    targetFilePaths.clear();
    validate();
  }


  setRepoName(String newRepoName) {
    repoName = newRepoName;
    validate();
  }

  setIfAutoSave(bool value) {
    autoSave = value;
    validate();
  }
  setAutoSaveIntervel(int value) {
    autoSaveInterval=value;
    validate();
  }

  setAutoSaveNums(int value) {
    autoSavesNums=value;
    validate();
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
    this.autoSaveInterval = 60,
    this.autoSavesNums = 40,
    required this.targetFilePaths,
  });
}
