import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:visual_branching/util/common.dart';

class Repo {
  String repoName;
  String repoIdName;
  late ValueKey repoKey;
  bool isAutoSave;

//对照表
// leaf保存名称:文件绝对路径
  Map<String, String> comparionTable;
//目标文件绝对路径的字符串列表
  // List<String> targeFiles;

//自动保存时间间隔(分钟)
  int autoSaveIntevalMins;
  //自动保存 的 备份 保有个数
  int autoSaveNum;

//repo 路径，但是不会存入json，仅用于运行时访问
  String repoPath;

//标头节点key
//todo 标头表示最接近真实目标文件状态的版本（节点）?
  ValueKey<String>? headerLeafKey;
  // 每棵树的根节点（不可见节点的直接子孩子节点）
  List<ValueKey<String>> rootLeafKeys;
  List<Leaf> leafs;

  //recycle bin
  List<Leaf> leafRcyclBin;

  Map<ValueKey<String>, List<ValueKey<String>>> realtions;

  static String _genLeafName(int nowUnixEpoch, NodeType nodeType) {
    switch (nodeType) {
      case NodeType.manually:
        return nowUnixEpoch.toString() + "N" + "M";
      case NodeType.automatically:
        return nowUnixEpoch.toString() + "N" + "A";
    }
  }

  static bool _genCanEdit(NodeType nodeType) {
    switch (nodeType) {
      case NodeType.manually:
        return true;
      case NodeType.automatically:
        return false;
    }
  }

  static bool _loadCanEdit(String leafIdName) {
    String lastChar = leafIdName.substring(leafIdName.length - 2);
    switch (lastChar) {
      case "M":
        return true;
      case "A":
        return false;

      default:
        {
          return false;
        }
    }
  }

  _copyTo(String filePath, CopyDirection direction) {
    //todo 异步
    Directory checkDir = Directory(filePath);
    if (!checkDir.existsSync()) {
      checkDir.createSync();
    }

    //todo 出错控制

    //todo 文件目标已被删除,报错？
    switch (direction) {
      case CopyDirection.target2Leaf:
        {
          //创建文件路径，复制文件
          comparionTable.forEach((saveFileName, targetFileAbsPath) {
            File tempFile = File(targetFileAbsPath);
            tempFile.copySync(filePath + Platform.pathSeparator + saveFileName);
          });
        }
        break;
      case CopyDirection.leaf2Target:
        {
          //todo 先将现有target存入缓冲区(回收站)

          //覆盖目标文件
          comparionTable.forEach((saveFileName, targetFileAbsPath) {
            File tempFile =
                File(filePath + Platform.pathSeparator + saveFileName);
            tempFile.copySync(targetFileAbsPath);
          });
        }
        break;
    }
  }

  static runAutoSave() {
    //todo impl
  }

  retirveToLeaf(ValueKey targetLeafKey) {
    //不会出现不在leafs中的key
    // final targetLeaf =
    //     leafs.firstWhere((element) => element.leafKey == targetLeafKey);

    //临时leaf,创建一个现有备份，直接送入回收站
    //不能newLeaf方法,不移动标头不创建relation
    final tempLeaf = Leaf(
        ValueKey("${DateTime.now().millisecondsSinceEpoch}NA"),
        false,
        "发生覆盖时的备份");
    leafRcyclBin.add(tempLeaf);

    //复制文件直接到回收站
    _copyTo(
        "${repoPath}${Platform.pathSeparator}recycleBin${Platform.pathSeparator}${tempLeaf.leafKey.value}",
        CopyDirection.target2Leaf);

    //覆盖到目标文件处
    _copyTo(repoPath + Platform.pathSeparator + targetLeafKey.value,
        CopyDirection.leaf2Target);

    //移动标头到回退到的leaf
    headerLeafKey = targetLeafKey as ValueKey<String>?;

    //写入json
    toJsonFile();
  }

  delLeaf(ValueKey targetLeafKey) async {
    //移动节点(逻辑删除,移动到回收站List)
    Leaf targetLeaf =
        leafs.firstWhere((element) => element.leafKey == targetLeafKey);
    leafRcyclBin.add(targetLeaf);
    leafs.remove(targetLeaf);

    //todo 清除relation

    //移动文件

    String leafPath =
        repoName + Platform.pathSeparator + targetLeaf.leafKey.value;

    final leafDircetory = Directory(leafPath);
    final recyclePath = "$repoPath${Platform.pathSeparator}recycleBin";

//todo 异步

    if (Directory(recyclePath).existsSync()) {
      try {
        await leafDircetory.rename(
            "$repoPath${Platform.pathSeparator}recycleBin${Platform.pathSeparator}${targetLeaf.leafKey.value}");
      } on FileSystemException catch (e) {
        //文件夹移动失败

      }
    } else {
      //todo 垃圾桶不存在
    }

    //todo 垃圾桶清理

    //外部刷新
  }

  Future<Leaf> newLeaf(NodeType nodeType, String leafAnnotation) async {
    //创建一个leaf，并进行实际文件复制，并加入到repo
    final nowUnixEpoch = DateTime.now().millisecondsSinceEpoch;

    String newLeafName = _genLeafName(nowUnixEpoch, nodeType);

    Leaf newLeaf =
        Leaf(ValueKey(newLeafName), _genCanEdit(nodeType), leafAnnotation);

    //创建leaf 文件夹
    Directory leafPath = Directory(
        "${Platform.resolvedExecutable.substring(0, (Platform.resolvedExecutable.length - Platform.resolvedExecutable.split(Platform.pathSeparator).last.length - 1))}${Platform.pathSeparator}repos${Platform.pathSeparator}$repoIdName${Platform.pathSeparator}${newLeaf.leafKey.value}");
    await leafPath.create();

    //复制文件
    _copyTo(leafPath.path, CopyDirection.target2Leaf);

    leafs.add(newLeaf);
    if (headerLeafKey == null) {
      //无标头节点
      rootLeafKeys.add(newLeaf.leafKey);
      headerLeafKey = newLeaf.leafKey;
    } else {
      if (realtions[headerLeafKey as ValueKey<String>] == null) {
        realtions[headerLeafKey as ValueKey<String>] = [newLeaf.leafKey];
      } else {
        realtions[headerLeafKey as ValueKey<String>]?.add(newLeaf.leafKey);
      }
    }

//永远推进标头
    headerLeafKey = newLeaf.leafKey;
    //todo IO频繁？
    toJsonFile();

    return newLeaf;
  }

  toJsonFile() {
    //todo 直接覆盖文件？
    Map repoMap = {
      "config": {
        "repoName": repoName,
        "autoSave": isAutoSave,
        "conparsionTable": comparionTable,
        "autoSaveInterval": autoSaveIntevalMins,
        "autoSaveNums": autoSaveNum
      },
      "repoIdName": repoIdName,
      "headerLeaf": headerLeafKey?.value,
      "roots": rootLeafKeys.map((e) => e.value).toList(),
      "leafs": Map.fromEntries(leafs.map((e) => e.toMapEntry())),
      "leafRcyclBin": Map.fromEntries(leafRcyclBin.map((e) => e.toMapEntry())),
      "relations": realtions.map((source, destinations) =>
          MapEntry(source.value, destinations.map((e) => e.value).toList()))
    };

    File jsonFile =
        File(repoPath + Platform.pathSeparator + repoIdName + ".json");
    //todo 异步
    jsonFile.writeAsStringSync(json.encode(repoMap));
  }

  static Future<Repo> newRepo(
    String repoName,
    bool autoSave,
    List<String> targetFilePaths,
    int autoSaveIntervalMinutes,
    int autoSaveNums,
  ) async {
    final nowUnixEpoch = DateTime.now().millisecondsSinceEpoch;

    //创建文件夹
    //检查repos文件夹是否存在
    // Directory exePath = File(Platform.resolvedExecutable).parent;

    //创建repo文件夹
    //同时创建回收站文件夹
    String repoPath =
        "${Platform.resolvedExecutable.substring(0, (Platform.resolvedExecutable.length - Platform.resolvedExecutable.split(Platform.pathSeparator).last.length - 1))}${Platform.pathSeparator}repos${Platform.pathSeparator}${nowUnixEpoch}T";
    Directory recycleBinPath =
        Directory("$repoPath${Platform.pathSeparator}recycleBin");

    await recycleBinPath.create(recursive: true);

    //生成对照表
    Map<String, String> newComparsionTab = {};
    for (String element in targetFilePaths) {
      List<String> splitd = element.split(Platform.pathSeparator);
      //todo 风险？
      newComparsionTab[splitd[splitd.length - 2] + splitd.last] = element;
    }

    return Repo(
        repoName,
        nowUnixEpoch.toString() + "T",
        repoPath,
        autoSave,
        newComparsionTab,
        autoSaveIntervalMinutes,
        autoSaveNums,
        null, [], [], [], {});
  }

  static fromJson(String jsonFilePath) {
    //从json文件读取库
    File jsonFile = File(jsonFilePath);
    //todo异步
    Map<String, dynamic> repoJsonObj = json.decode(jsonFile.readAsStringSync());
    //todo 错误检测

    //leafIdName , annotation
    Map<String, dynamic> tempPair = repoJsonObj["leafs"];

    List<Leaf> leafList = [];
    tempPair.forEach((leafIdName, annotation) {
      leafList.add(
          Leaf(ValueKey(leafIdName), _loadCanEdit(leafIdName), annotation));
    });

//leafIdName , annotation
    tempPair = repoJsonObj["leafRcyclBin"];

    List<Leaf> leafRcyclBin = [];
    tempPair.forEach((leafIdName, annotation) {
      leafRcyclBin.add(
          Leaf(ValueKey(leafIdName), _loadCanEdit(leafIdName), annotation));
    });

    String headerLeafIdName = repoJsonObj["headerLeaf"];

    List<String> rootsIdNames = List<String>.from(repoJsonObj["roots"]);
    List<ValueKey<String>> rootsKeys =
        rootsIdNames.map((e) => ValueKey(e)).toList();

    Map temp = repoJsonObj["relations"];
    Map<String, List<String>> realtionsidNames = {};
    temp.forEach((key, value) {
      realtionsidNames[key] = List<String>.from(value);
    });

    Map<ValueKey<String>, List<ValueKey<String>>> realtionKeys =
        realtionsidNames.map((srcIdName, desIdNames) => MapEntry(
            ValueKey(srcIdName),
            desIdNames.map((idName) => ValueKey(idName)).toList()));

    return Repo(
        repoJsonObj["config"]["repoName"],
        repoJsonObj["repoIdName"],
        jsonFilePath.substring(
            0,
            jsonFilePath.length -
                jsonFilePath.split(Platform.pathSeparator).last.length -
                1),
        repoJsonObj["config"]["autoSave"],
        Map.from(repoJsonObj["config"]["conparsionTable"]),
        repoJsonObj["config"]["autoSaveInterval"],
        repoJsonObj["config"]["autoSaveNums"],
        ValueKey(headerLeafIdName),
        rootsKeys,
        leafList,
        leafRcyclBin,
        realtionKeys);
  }

  Repo(
      this.repoName,
      this.repoIdName,
      this.repoPath,
      this.isAutoSave,
      this.comparionTable,
      this.autoSaveIntevalMins,
      this.autoSaveNum,
      this.headerLeafKey,
      this.rootLeafKeys,
      this.leafs,
      this.leafRcyclBin,
      this.realtions) {
    repoKey = ValueKey(repoName);
  }
}

class Leaf {
  //todo 通过leaf名字字符串生成
  late ValueKey<String> leafKey;

  //由leaf名字 字符串最后一个字母决定，M手动管理，A自动管理
  late bool canEdit;

  //leaf名称 前缀为创建时间的utc Linux时间戳
  // late DateTime createdTime;

  // late String filePath;
  late String annotation;

  MapEntry<String, String> toMapEntry() {
    return MapEntry(leafKey.value, annotation);
  }
  // static Leaf loadLeaf(
  //     String leafName, String leafFilePath, String leafAnnotation) {
  //   return Leaf(
  //       ValueKey(leafName),
  //       DateTime.parse(leafName.split("N")[0]),
  //       //todo 风险
  //       leafName.endsWith("M"),
  //       leafAnnotation);
  // }

  Leaf(this.leafKey, this.canEdit, this.annotation);
}
