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

//标头节点key
//标头表示最接近真实目标文件状态的版本（节点）?
  ValueKey<String>? headerLeafKey;
  // 每棵树的根节点（不可见节点的直接子孩子节点）
  List<ValueKey<String>> rootLeafKeys;
  List<Leaf> leafs;

  //recycle bin
  List<Leaf> leafRcyclBin;

  //auto Saves
  List<Leaf> autoSaves;

  ///these properties will not be writed to json
  String repoPath;

  Map<ValueKey<String>, List<ValueKey<String>>> realtions;

  static delRepo(Repo repo) {
    //TODO 停止自动保存

    try {
      //直接删除repo文件夹
      Directory(repo.repoPath).deleteSync(recursive: true);
    } on FileSystemException catch (e) {
      //文件夹删除
      print(e);
    }
  }

  static runAutoSave() {
    //TODO impl
  }

  Leaf getLeafByKey(ValueKey<String> leafKey, LeafFrom belonging) {
    switch (belonging) {
      case LeafFrom.leafs:
        return leafs.firstWhere((element) => element.leafKey == leafKey);
      case LeafFrom.recycleBin:
        return leafRcyclBin.firstWhere((element) => element.leafKey == leafKey);
      case LeafFrom.autoSave:
        return autoSaves.firstWhere((element) => element.leafKey == leafKey);
    }
  }

  _copyTo(String filePath, CopyDirection direction) async {
    //todo 异步
    // 传入的filePath可能为leafIdName

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
      case CopyDirection.recycle2Leafs:
        {
          //filePath will be [targetLeaf.leafKey.value] the Id name of leaf, check delLeaf
          //todo [genLeafPath] 的参数类型可否直接string
          String leafPath =
              genLeafPath(ValueKey(filePath), LeafFrom.recycleBin);

          final leafDircetory = Directory(leafPath);
          // final recyclePath = "$repoPath${Platform.pathSeparator}recycleBin";

          if (leafDircetory.existsSync()) {
            try {
              await leafDircetory.rename(
                  "$repoPath${Platform.pathSeparator}leafs${Platform.pathSeparator}$filePath");
            } on FileSystemException catch (e) {
              //文件夹移动失败
              print(e);
            }
          } else {
            //todo 垃圾桶不存在
          }

          break;
        }
      case CopyDirection.leafs2recycle:
        {
          //todo 基本一致 [case recycle2Leafs]

          String leafPath = genLeafPath(ValueKey(filePath), LeafFrom.leafs);

          final leafDircetory = Directory(leafPath);

          final recyclePath = "$repoPath${Platform.pathSeparator}recycleBin";

          if (Directory(recyclePath).existsSync()) {
            try {
              await leafDircetory.rename(
                  "$repoPath${Platform.pathSeparator}recycleBin${Platform.pathSeparator}$filePath");
            } on FileSystemException catch (e) {
              //文件夹移动失败
              print(e);
            }
          } else {
            //todo 垃圾桶不存在
          }

          //todo 垃圾桶清理
          break;
        }
      case CopyDirection.autoSave2Leafs:
        // TODO: Handle this case.
        break;
      case CopyDirection.target2recycle:
        // todo 与 target2Leaf完全一致,传入参数改为只传leafIdname？
        {
          final leafRecycleDir = Directory(filePath);
          if (!leafRecycleDir.existsSync()) {
            leafRecycleDir.createSync(recursive: true);
          }

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
          break;
        }
      case CopyDirection.target2AutoSave:
        // TODO: Handle this case.
        break;
    }
  }

  String genLeafPath(ValueKey<String> key, LeafFrom leafType) {
    final String leafBelongPath;
    switch (leafType) {
      case LeafFrom.leafs:
        leafBelongPath = "leafs";
        break;
      case LeafFrom.recycleBin:
        leafBelongPath = "recycleBin";
        break;
      case LeafFrom.autoSave:
        leafBelongPath = "autoSaves";
        break;
    }
    return "$repoPath${Platform.pathSeparator}$leafBelongPath${Platform.pathSeparator}${key.value}";
  }

  Leaf _getLastLeaf() {
    return leafs.reduce((value, element) =>
        element.createdTime.isAfter(value.createdTime) ? element : value);
  }

  retirveToLeaf(ValueKey<String> targetLeafKey, LeafFrom belonging) {
    //targetLeafKey可能来源 回收站/自动保存/leafs

    switch (belonging) {
      case LeafFrom.leafs:
        break;
      case LeafFrom.recycleBin:
        {
          final targetLeaf = getLeafByKey(targetLeafKey, LeafFrom.recycleBin);
          targetLeaf.annotation = "由回收站还原:${targetLeaf.annotation}";
          leafs.add(targetLeaf);
          leafRcyclBin.remove(targetLeaf);
          //建立关系
          _headerRelation(targetLeafKey, false);

          // 移动节点文件
          _copyTo(targetLeafKey.value, CopyDirection.recycle2Leafs);
          break;
        }
      case LeafFrom.autoSave:
        {
          final targetLeaf = getLeafByKey(targetLeafKey, LeafFrom.autoSave);
          leafs.add(targetLeaf);
          autoSaves.remove(targetLeaf);
          _headerRelation(targetLeafKey, false);
          break;
        }
    }

    //临时leaf,创建一个现有备份，直接送入回收站
    //不能newLeaf方法,不移动标头不创建relation

    final backUpLeaf = Leaf(
        ValueKey("${DateTime.now().millisecondsSinceEpoch}NA"), "发生覆盖时的备份");
    leafRcyclBin.add(backUpLeaf);

    //复制文件直接到回收站
    //现有新copy方向 [CopyDirection.target2recycle]
    _copyTo(
        "$repoPath${Platform.pathSeparator}recycleBin${Platform.pathSeparator}${backUpLeaf.leafKey.value}",
        CopyDirection.target2recycle);
    // _copyTo(
    //     "$repoPath${Platform.pathSeparator}recycleBin${Platform.pathSeparator}${backUpLeaf.leafKey.value}",
    //     CopyDirection.target2Leaf);

    //覆盖到目标文件处
    _copyTo(
        genLeafPath(targetLeafKey, LeafFrom.leafs), CopyDirection.leaf2Target);

    //移动标头到回退到的leaf
    headerLeafKey = targetLeafKey;

    //写入json
    toJsonFile();
  }

  ValueKey<String>? getParentLeaf(ValueKey<String> targetLeafKey) {
    MapEntry<ValueKey<String>, List<ValueKey<String>>> upStream = realtions
        .entries
        .firstWhere((pair) => pair.value.contains(targetLeafKey),
            orElse: () => const MapEntry(ValueKey(""), []));
    return upStream.key.value.isEmpty ? null : upStream.key;
  }

  delLeaf(ValueKey<String> targetLeafKey) async {
    //移动节点(逻辑删除,移动到回收站List)
    final Leaf targetLeaf = getLeafByKey(targetLeafKey, LeafFrom.leafs);
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
        // 当移除某个分支上的唯一节点（没有父子）

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
    _copyTo(targetLeafKey.value, CopyDirection.leafs2recycle);

    toJsonFile();
    //外部刷新
  }

  _headerRelation(ValueKey<String> newLeafKey, bool setRoot) {
    //update realation depends on if header exist
    if (headerLeafKey == null || setRoot) {
      //无标头节点
      rootLeafKeys.add(newLeafKey);
      headerLeafKey = newLeafKey;
    } else {
      if (realtions[headerLeafKey as ValueKey<String>] == null) {
        realtions[headerLeafKey as ValueKey<String>] = [newLeafKey];
      } else {
        realtions[headerLeafKey as ValueKey<String>]?.add(newLeafKey);
      }
    }
  }

  Future<Leaf> newLeaf(
      NodeType nodeType, String leafAnnotation, bool setRoot) async {
    //创建一个leaf，并进行实际文件复制，并加入到repo
    final nowUnixEpoch = DateTime.now().millisecondsSinceEpoch;

    String newLeafName = _genLeafName(nowUnixEpoch, nodeType);

    Leaf newLeaf = Leaf(ValueKey(newLeafName), leafAnnotation);

    //创建leaf 文件夹

    Directory leafPath =
        Directory(genLeafPath(newLeaf.leafKey, LeafFrom.leafs));

    await leafPath.create();

    //复制文件
    _copyTo(leafPath.path, CopyDirection.target2Leaf);

    leafs.add(newLeaf);
    _headerRelation(newLeaf.leafKey, setRoot);

//永远推进标头
    headerLeafKey = newLeaf.leafKey;
    //todo IO频繁？
    toJsonFile();

    return newLeaf;
  }

  alterLeafAnno(ValueKey<String> leafKey, String newAnno) {
    getLeafByKey(leafKey, LeafFrom.leafs).annotation = newAnno;
    toJsonFile();
  }

  alterRepo(String newRepoName, bool newAutoSave, int newAutoSaveInterval,
      int newAutoSavesNums) {
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
        Directory("$repoPath${Platform.pathSeparator}recycleBin");
    recycleBin.deleteSync(recursive: true);
    recycleBin.createSync();
    toJsonFile();
  }

  static String _genLeafName(int nowUnixEpoch, NodeType nodeType) {
    switch (nodeType) {
      case NodeType.manually:
        return "${nowUnixEpoch}NM";
      case NodeType.automatically:
        return "${nowUnixEpoch}NA";
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
    //直接创建，即使配置没有开启
    Directory autoSavePath =
        Directory("$repoPath${Platform.pathSeparator}autoSaves");

    Directory leafsPath = Directory("$repoPath${Platform.pathSeparator}leafs");

    await autoSavePath.create(recursive: true);
    await leafsPath.create(recursive: true);

    //生成对照表
    Map<String, String> newComparsionTab = {};
    for (String element in targetFilePaths) {
      List<String> splitd = element.split(Platform.pathSeparator);
      //Windows下最短:目标文件在C盘根， C:/targetFile
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

  static Future<Repo> fromJson(String jsonFilePath) async {
    //从json文件读取库
    File jsonFile = File(jsonFilePath);
    final jsonString = await jsonFile.readAsString();

    Map<String, dynamic> repoJsonObj = json.decode(jsonString);
    //TODO 外部错误检测

    //leafIdName , annotation
    Map<String, dynamic> tempMap = repoJsonObj["leafs"];

    List<Leaf> leafList = [];
    tempMap.forEach((leafIdName, annotation) {
      leafList.add(Leaf(ValueKey(leafIdName), annotation));
    });

//parse recycle bin
    tempMap = repoJsonObj["leafRcyclBin"];

    List<Leaf> leafRcyclBin = [];
    tempMap.forEach((leafIdName, annotation) {
      leafRcyclBin.add(Leaf(ValueKey(leafIdName), annotation));
    });

//parse autoSaves
    tempMap = repoJsonObj["leafRcyclBin"];

    List<Leaf> autoSaves = [];
    tempMap.forEach((leafIdName, annotation) {
      autoSaves.add(Leaf(ValueKey(leafIdName), annotation));
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

  late DateTime createdTime;

  // late String filePath;
  late String annotation;

  MapEntry<String, String> toMapEntry() {
    return MapEntry(leafKey.value, annotation);
  }

  Leaf(this.leafKey, this.annotation) {
    if (leafKey.value.isEmpty) {
      //当创建graph基底节点，传入 [Leaf(const ValueKey(""), "")]
      createdTime = DateTime.now();
      return;
    } else {
      createdTime = DateTime.fromMillisecondsSinceEpoch(
          int.parse(leafKey.value.substring(0, leafKey.value.length - 2)));
    }
  }
}
