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
//标头表示最接近真实目标文件状态的版本（节点）?
  ValueKey<String>? headerLeafKey;
  // 每棵树的根节点（不可见节点的直接子孩子节点）
  List<ValueKey<String>> rootLeafKeys;
  List<Leaf> leafs;

  //recycle bin
  List<Leaf> leafRcyclBin;

  //auto Saves
  //todo 取消canEdit？
  List<Leaf> autoSaves;

  Map<ValueKey<String>, List<ValueKey<String>>> realtions;

  static delRepo(Repo repo) {
    //todo 停止自动保存

    try {
      //直接删除repo文件夹
      Directory(repo.repoPath).deleteSync(recursive: true);
    } on FileSystemException catch (e) {
      //文件夹删除
      print(e);
    }
  }

  static runAutoSave() {
    //todo impl
  }

  Leaf getLeafByKey(ValueKey<String> leafKey) {
    //todo 确保leafKey 存在？
    return leafs.firstWhere((element) => element.leafKey == leafKey);
  }

  _copyTo(String filePath, CopyDirection direction) {
    //todo 异步
    Directory checkDir = Directory(filePath);
    if (!checkDir.existsSync()) {
      checkDir.createSync(recursive: true);
    }

    //todo 出错控制

    //todo 文件目标已被删除,报错？
    switch (direction) {
      case CopyDirection.target2Leaf:
        {
          //创建文件路径，复制文件
          comparionTable.forEach((saveFileName, targetFileAbsPath) {
            File tempFile = File(targetFileAbsPath);
            //todo 异步
            if (tempFile.existsSync()) {
              tempFile
                  .copySync(filePath + Platform.pathSeparator + saveFileName);
            } else {
              //todo 目标文件被删除，如何警告？
              print(" 目标文件被删除");
            }
          });
        }
        break;
      case CopyDirection.leaf2Target:
        {
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

  String genLeafPath(ValueKey<String> key) {
    return "$repoPath${Platform.pathSeparator}leafs${Platform.pathSeparator}${key.value}";
  }

  Leaf _getLastLeaf() {
    return leafs.reduce((value, element) =>
        element.createdTime.isAfter(value.createdTime) ? element : value);
  }

  retirveToLeaf(ValueKey<String> targetLeafKey) {
    //不会出现不在leafs中的key

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
    _copyTo(genLeafPath(targetLeafKey), CopyDirection.leaf2Target);

    //移动标头到回退到的leaf
    headerLeafKey = targetLeafKey as ValueKey<String>?;

    //写入json
    toJsonFile();
  }

  delLeaf(ValueKey<String> targetLeafKey) async {
    //移动节点(逻辑删除,移动到回收站List)
    Leaf targetLeaf = getLeafByKey(targetLeafKey);
    leafRcyclBin.add(targetLeaf);
    leafs.remove(targetLeaf);

    //更新relation
    // 将子节点连到父节点

    MapEntry<ValueKey<String>, List<ValueKey<String>>> upStream = realtions
        .entries
        .firstWhere((pair) => pair.value.contains(targetLeafKey),
            orElse: () => const MapEntry(ValueKey(""), []));
    MapEntry<ValueKey<String>, List<ValueKey<String>>> downStream =
        realtions.entries.firstWhere((pair) => pair.key == targetLeafKey,
            orElse: () => const MapEntry(ValueKey(""), []));

// 当被删除节点为标头，向上设为父节点，向下寻找子节点中创建时间最晚的，或空（整个repo最后一个节点）

    if (upStream.value.isEmpty && downStream.value.isEmpty) {
      if (leafs.isEmpty) {
        //只有目标一个节点（已被移除）
        headerLeafKey = null;
      } else {
        // todo 当移除某个分支上的唯一节点（没有父子）

        //删除的是某个分支的唯一节点，不动标头

        //退到leaf数组最新的节点
        if (targetLeafKey == headerLeafKey) {
          headerLeafKey = _getLastLeaf().leafKey;
        }
      }
      rootLeafKeys.remove(targetLeafKey);
    } else {
      if (downStream.value.isEmpty) {
        //当要删除的leaf为分支末尾时，找不到子节点
        realtions[upStream.key]?.remove(targetLeafKey);
        if (headerLeafKey == targetLeafKey) {
          //设置标头为父节点
          headerLeafKey = upStream.key;
        }
      } else {
        if (headerLeafKey == targetLeafKey) {
          //设置标头为子节点中最晚创建的
          int youngestChild = 0;
          ValueKey<String> maxLeafKey = const ValueKey("");
          for (var childLeafKey in downStream.value) {
            //毫秒数对比更快？
            final millSeconds = _parseStamp(childLeafKey.value);
            if (millSeconds > youngestChild) {
              youngestChild = millSeconds;
              maxLeafKey = childLeafKey;
            }
          }
          headerLeafKey = maxLeafKey;
        }
        if (upStream.value.isEmpty) {
          //当要删除的leaf为root节点，找不到父节点

          realtions.remove(downStream.key);

          rootLeafKeys.remove(targetLeafKey);
          rootLeafKeys.addAll(downStream.value);
        } else {
          realtions[upStream.key]?.addAll(downStream.value);
          realtions[upStream.key]?.remove(targetLeafKey);
          realtions.remove(downStream.key);
        }
      }
    }

    //移动文件

    String leafPath = genLeafPath(targetLeafKey);

    final leafDircetory = Directory(leafPath);
    final recyclePath = "$repoPath${Platform.pathSeparator}recycleBin";

    //todo 异步 放到函数开始？

    if (Directory(recyclePath).existsSync()) {
      try {
        await leafDircetory.rename(
            "$repoPath${Platform.pathSeparator}recycleBin${Platform.pathSeparator}${targetLeaf.leafKey.value}");
      } on FileSystemException catch (e) {
        //文件夹移动失败
        print(e);
      }
    } else {
      //todo 垃圾桶不存在
    }

    //todo 垃圾桶清理

    toJsonFile();
    //外部刷新
  }

  Future<Leaf> newLeaf(
      NodeType nodeType, String leafAnnotation, bool isRoot) async {
    //创建一个leaf，并进行实际文件复制，并加入到repo
    final nowUnixEpoch = DateTime.now().millisecondsSinceEpoch;

    String newLeafName = _genLeafName(nowUnixEpoch, nodeType);

    Leaf newLeaf =
        Leaf(ValueKey(newLeafName), _genCanEdit(nodeType), leafAnnotation);

    //创建leaf 文件夹

    Directory leafPath = Directory(genLeafPath(newLeaf.leafKey));

    await leafPath.create();

    //复制文件
    _copyTo(leafPath.path, CopyDirection.target2Leaf);

    leafs.add(newLeaf);
    if (headerLeafKey == null || isRoot) {
      //无标头节点
      rootLeafKeys.add(newLeaf.leafKey);
      headerLeafKey = newLeaf.leafKey;
    } else {
      //todo 简化？
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

  alterLeafAnno(ValueKey<String> leafKey, String newAnno) {
    getLeafByKey(leafKey).annotation = newAnno;
    toJsonFile();
  }

  alterRepo(String newRepoName,bool newAutoSave,int newAutoSaveInterval,int newAutoSavesNums) {
    repoName = newRepoName;
    isAutoSave = newAutoSave;
    autoSaveIntevalMins = newAutoSaveInterval;
    autoSaveNum = newAutoSavesNums;
    toJsonFile();
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
      "autoSaves": Map.fromEntries(autoSaves.map((e) => e.toMapEntry())),
      "relations": realtions.map((source, destinations) =>
          MapEntry(source.value, destinations.map((e) => e.value).toList()))
    };

    File jsonFile = File("$repoPath${Platform.pathSeparator}$repoIdName.json");
    //todo 异步
    jsonFile.writeAsStringSync(json.encode(repoMap));
  }

  clearRecycleBin() {
    leafRcyclBin.clear();
    //删除回收站文件夹
    //todo 出错控制
    //todo 常用路径的Directory对象作为repo属性？
    final recycleBin =
        Directory(repoPath + Platform.pathSeparator + "recycleBin");
    recycleBin.deleteSync(recursive: true);
    recycleBin.createSync();
    toJsonFile();
  }

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

  static int _parseStamp(String leafIdName) {
    return int.parse(leafIdName.substring(0, leafIdName.length - 2));
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

    //创建自动保存文件夹
    Directory autoSavePath =
        Directory("$repoPath${Platform.pathSeparator}autoSaves");

    Directory leafsPath = Directory("$repoPath${Platform.pathSeparator}leafs");

    await recycleBinPath.create(recursive: true);
    await autoSavePath.create(recursive: true);
    await leafsPath.create(recursive: true);

    //生成对照表
    Map<String, String> newComparsionTab = {};
    for (String element in targetFilePaths) {
      List<String> splitd = element.split(Platform.pathSeparator);
      //todo 风险？
      newComparsionTab[splitd[splitd.length - 2] + splitd.last] = element;
    }

    return Repo(
        repoName,
        "${nowUnixEpoch}T",
        repoPath,
        autoSave,
        newComparsionTab,
        autoSaveIntervalMinutes,
        autoSaveNums,
        null, [], [], [], [], {});
  }

  static fromJson(String jsonFilePath) {
    //从json文件读取库
    File jsonFile = File(jsonFilePath);
    //todo异步
    Map<String, dynamic> repoJsonObj = json.decode(jsonFile.readAsStringSync());
    //todo 错误检测

    //leafIdName , annotation
    Map<String, dynamic> tempMap = repoJsonObj["leafs"];

    List<Leaf> leafList = [];
    tempMap.forEach((leafIdName, annotation) {
      leafList.add(
          Leaf(ValueKey(leafIdName), _loadCanEdit(leafIdName), annotation));
    });

//parse recycle bin
    tempMap = repoJsonObj["leafRcyclBin"];

    List<Leaf> leafRcyclBin = [];
    tempMap.forEach((leafIdName, annotation) {
      leafRcyclBin.add(
          Leaf(ValueKey(leafIdName), _loadCanEdit(leafIdName), annotation));
    });

//parse autoSaves
    tempMap = repoJsonObj["leafRcyclBin"];

    List<Leaf> autoSaves = [];
    tempMap.forEach((leafIdName, annotation) {
      autoSaves.add(
          Leaf(ValueKey(leafIdName), _loadCanEdit(leafIdName), annotation));
    });

    String? headerLeafIdName = repoJsonObj["headerLeaf"];

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
        headerLeafIdName == null ? null : ValueKey(headerLeafIdName),
        rootsKeys,
        leafList,
        leafRcyclBin,
        autoSaves,
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
      this.autoSaves,
      this.realtions) {
    repoKey = ValueKey(repoName);
  }
}

class Leaf {
  //通过leaf名字字符串生成
  //leaf名称 前缀为创建时间的utc Linux时间戳
  late ValueKey<String> leafKey;

  //由leaf名字 字符串最后一个字母决定，M手动管理，A自动管理
  late bool canEdit;

  late DateTime createdTime;

  // late String filePath;
  late String annotation;

  MapEntry<String, String> toMapEntry() {
    return MapEntry(leafKey.value, annotation);
  }

  Leaf(this.leafKey, this.canEdit, this.annotation) {
    if (leafKey.value.isEmpty) {
      //todo 时区问题?
      createdTime = DateTime.now();
      return;
    } else {
      createdTime = DateTime.fromMillisecondsSinceEpoch(
          int.parse(leafKey.value.substring(0, leafKey.value.length - 2)));
    }
  }
}
