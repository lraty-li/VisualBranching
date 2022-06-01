import 'dart:async';
import 'dart:convert';
import 'dart:io';

class AutoSaveManag {
  List<AutoSaveInstance> instances;

  cancelAllTimer() {
    for (var element in instances) {
      element.saveTimer.cancel();
    }
  }

  setAllautoSave(bool newCtl) {
    for (var element in instances) {
      element.autoSaveCTL = newCtl;
    }
  }

  setAllverbose(bool newCtl) {
    for (var element in instances) {
      element.verboseCTL = newCtl;
    }
  }

  reflashByIdName() {}

  removeByIdName() {}

  AutoSaveManag({required this.instances});
}

// UI端不会有自动保存写入，分离autoSave.json

// a repo thst enable autosave
class AutoSaveInstance {
  String repoName;
  String repoIdName;
  //对照表
// leaf保存名称:文件绝对路径
  Map<String, String> comparionTable;

  //自动保存时间间隔(分钟)
  int autoSaveIntevalMins;
  //自动保存 的 备份 保有个数
  int autoSaveNum;

  bool autoSaveCTL;
  bool verboseCTL;
  late Timer saveTimer;
  late List<String> autoSaveIdNames;
  late File jsonObj;

  // 是否显示保存信息
  late bool showVerboseCTL;
  // 批量自动保存清理，计数器,默认为 [autoSaveNum] 的一半
  // late int batchCleanerCounter;

  showInfo(String msg) {
    print("[info] $repoName ${DateTime.now()} : $msg");
  }

  showVerbose(String msg) {
    print("[verbose] $repoName ${DateTime.now()} : $msg");
  }

  showError(String msg) {
    print("[ERROR] $repoName ${DateTime.now()} : $msg");
  }

  AutoSaveInstance(
      {required this.repoName,
      required this.repoIdName,
      required this.comparionTable,
      required this.autoSaveIntevalMins,
      required this.autoSaveNum,
      this.autoSaveCTL = false,
      this.verboseCTL = true}) {
    final repoPathStr =
        "${Directory.current.path}${Platform.pathSeparator}repos${Platform.pathSeparator}$repoIdName${Platform.pathSeparator}";

    //TODO 不存在则创建
    jsonObj = File("${repoPathStr}autoSaves.json");
    autoSaveIdNames =
        List<String>.from(json.decode(jsonObj.readAsStringSync()));

    final autoSaveDir = Directory("${repoPathStr}autoSaves");

    if (!autoSaveDir.existsSync()) {
      autoSaveDir.createSync(recursive: true);
    }

    saveTimer = Timer.periodic(Duration(minutes: autoSaveIntevalMins), (timer) {
      if (autoSaveCTL) {
        if (autoSaveIdNames.length >= autoSaveNum) {
          //TODO 文件夹操作会触发UI端更新
          //TODO 确定最老备份？
          //清理自动保存,删除第一个(autoSaveIdNames最小为0)
          final String oldestIdName = "${autoSaveIdNames[0]}";
          autoSaveIdNames.removeAt(0);
          try {
            Directory(
                    "${autoSaveDir.path}${Platform.pathSeparator}$oldestIdName")
                .deleteSync(recursive: true);
            if (verboseCTL) {
              showVerbose("清理备份[$oldestIdName]完成");
            }
          } catch (e) {
            showError("清理备份[$oldestIdName]失败!!!!!!,请及时暂停自动保存");
            showError(e.toString());
          }
        }
        //创建节点文件夹
        try {
          final String leafIdName =
              "${DateTime.now().millisecondsSinceEpoch}NA";
          Directory("${autoSaveDir.path}${Platform.pathSeparator}$leafIdName")
              .createSync();

          // 复制目标文件到自动保存文件夹
          autoSaveIdNames.add(leafIdName);
          comparionTable.forEach((saveFileName, targetFileAbsPath) {
            File tempFile = File(targetFileAbsPath);
            if (tempFile.existsSync()) {
              //生成伪leafIdName，写入json
              jsonObj.writeAsStringSync(json.encode(autoSaveIdNames));

              tempFile.copySync(
                  "${autoSaveDir.path}${Platform.pathSeparator}$leafIdName${Platform.pathSeparator}$saveFileName");
            } else {
              //目标文件被删除 跳过本次保存
              showError(
                  "${tempFile.path.split(Platform.pathSeparator).last} 不存在, 跳过本该复制");
            }
          });

          if (verboseCTL) {
            showVerbose("$leafIdName 备份完成");
          }
        } catch (e) {
          //库被删除
          showError(e.toString());
          //TODO 保留错误信息
          showError("出错了！,取消 ${repoName} 的自动保存");
          timer.cancel();
        }
      }
    });
  }
}
