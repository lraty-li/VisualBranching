import 'package:flutter/cupertino.dart';

enum ShellLnkConfigEnum { exePath, repoIdName, saveTo }

class ShellLnkConfig extends ChangeNotifier {
  bool validated;

  String targetExePath;
  String targetRepoIdName;
  String shellLnkSaveToPath;

  _validate() {
    if (targetExePath.isNotEmpty &&
        targetRepoIdName.isNotEmpty &&
        shellLnkSaveToPath.isNotEmpty) {
      validated = true;

      notifyListeners();
    }
  }

  setProperty(String value, ShellLnkConfigEnum type) {
    switch (type) {
      case ShellLnkConfigEnum.exePath:
        targetExePath = value;
        break;
      case ShellLnkConfigEnum.repoIdName:
        targetRepoIdName = value;
        break;
      case ShellLnkConfigEnum.saveTo:
        shellLnkSaveToPath = value;
        break;
    }
    _validate();
  }

  ShellLnkConfig(
      {this.targetExePath = "",
      this.targetRepoIdName = "",
      this.shellLnkSaveToPath = "",
      this.validated = false});
}
