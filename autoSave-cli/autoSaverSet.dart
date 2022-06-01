import 'dart:async';
import 'dart:convert';
import 'dart:io';

class AutoSaveManag {
  List<AutoSaveInstance> instances;

  setAll(bool newCtl) {
    instances.forEach((element) {
      element.autoSaveCTL = newCtl;
    });

    reflashByIdName() {}

    removeByIdName() {}
  }

  AutoSaveManag({required this.instances});
}

//TODO 更新 repo json 冲突？
//TODO 回退到自动保存：移动/复制 leaf？
//TODO 接受“刷新配置”指令,从控制台stdin或管道，暂停（取消）全部自动保存并清除，重新读入？
// TODO UI端不会有自动保存写入，分离autoSave.json

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
  late Timer saveTimer;
  late List<String> autoSaveIdNames;
  late File jsonObj;

  AutoSaveInstance(
      {required this.repoName,
      required this.repoIdName,
      required this.comparionTable,
      required this.autoSaveIntevalMins,
      required this.autoSaveNum,
      this.autoSaveCTL = false}) {
    final repoPathStr =
        "${Directory.current.path}${Platform.pathSeparator}repos${Platform.pathSeparator}${repoIdName}${Platform.pathSeparator}";

    //TODO 不存在则创建
    jsonObj = File("${repoPathStr}autoSaves.json");
    autoSaveIdNames = List<String>.from(json.decode(jsonObj.readAsStringSync()));

    final autoSaveDir = Directory("${repoPathStr}autoSaves");

    if (!autoSaveDir.existsSync()) {
      autoSaveDir.createSync(recursive: true);
    }
    saveTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      if (autoSaveCTL) {
        //TODO 路径

        //创建节点文件夹
        final String leafIdName = "${DateTime.now().millisecondsSinceEpoch}NA";
        Directory("${autoSaveDir.path}${Platform.pathSeparator}${leafIdName}")
            .createSync();

        // 复制目标文件到自动保存文件夹
        comparionTable.forEach((saveFileName, targetFileAbsPath) {
          File tempFile = File(targetFileAbsPath);
          if (tempFile.existsSync()) {
            //TODO 生成伪leaf，写入json
            autoSaveIdNames.add(leafIdName);
            jsonObj.writeAsStringSync(json.encode(autoSaveIdNames));

            tempFile.copySync(
                "${autoSaveDir.path}${Platform.pathSeparator}${leafIdName}" +
                    Platform.pathSeparator +
                    saveFileName);
          } else {
            //TODO 目标文件被删除，关闭periodic? / 跳过本次保存
            print(" ${repoName}目标文件被删除");
          }
        });
      }

      //TODO batch 清理自动保存
    });
  }
}
