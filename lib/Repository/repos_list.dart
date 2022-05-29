import 'dart:io';

import 'package:flutter/material.dart';
import 'package:visual_branching/util/models.dart';

Widget? _ifAutoSaveIcon(bool autosave) {
  if (autosave) return const Icon(Icons.update);
  return null;
}

Future<List<Repo>> loadRepos() async {
  List<Repo> reposList = [];

//读取现有库
  Directory repoPath = Directory(
      "${Platform.resolvedExecutable.substring(0, (Platform.resolvedExecutable.length - Platform.resolvedExecutable.split(Platform.pathSeparator).last.length - 1))}${Platform.pathSeparator}repos");

  //todo 异步
  if (!repoPath.existsSync()) {
    repoPath.createSync();
  }
  List<FileSystemEntity> entitys = repoPath.listSync(recursive: false);

  for (FileSystemEntity element in entitys) {
    if (FileSystemEntity.isDirectorySync(element.path)) {
      //由json新建repo对象
      reposList.add(await Repo.fromJson(
          "${element.path}${Platform.pathSeparator}${element.path.split(Platform.pathSeparator).last}.json"));
    }
  }

  return reposList;
}

Widget buildRepoList(List<Repo> targetList, void Function(Repo) onTapfunc) {
  Widget divider1 = const Divider(
    color: Colors.blue,
  );
  Widget divider2 = const Divider(color: Colors.green);

  return ListView.separated(
    itemCount: targetList.length,

    //列表项构造器
    itemBuilder: (BuildContext context, int index) {
      return ListTile(
        title: Text(targetList[index].repoName),
        onTap: () {
          onTapfunc(targetList[index]);
        },
        trailing: _ifAutoSaveIcon(targetList[index].isAutoSave),
      );
    },
    //分割器构造器
    separatorBuilder: (BuildContext context, int index) {
      return index % 2 == 0 ? divider1 : divider2;
    },
  );
}
