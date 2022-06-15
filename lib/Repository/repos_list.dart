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

Widget buildRepoListView(BuildContext context, List<Repo> targetList,
    void Function(Repo) onTapfunc) {
  Widget divider1 = const Divider(
    color: Colors.blue,
  );
  Widget divider2 = const Divider(color: Colors.green);

  return SizedBox(
      width: MediaQuery.of(context).size.width * 0.5,
      height: MediaQuery.of(context).size.height * 0.6,
      child: FutureBuilder(
        future: loadRepos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              // 请求失败，显示错误
              return Text("Error: ${snapshot.error}");
            } else {
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
          } else {
            // 请求未结束，显示loading
            return const CircularProgressIndicator();
          }
        },
      ));
}

Widget buildChosingRepoListView(
    BuildContext context, void Function(Repo) onTapfunc) {
  Widget divider1 = const Divider(
    color: Colors.blue,
  );
  Widget divider2 = const Divider(color: Colors.green);

  return SizedBox(
      width: MediaQuery.of(context).size.width * 0.5,
      height: MediaQuery.of(context).size.height * 0.6,
      child: FutureBuilder(
        //TODO 每次选择都读取并实例化repo？
        future: loadRepos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              // 请求失败，显示错误
              return Text("Error: ${snapshot.error}");
            } else {
              final List<Repo> repoList = snapshot.data as List<Repo>;
              return ListView.separated(
                itemCount: repoList.length,

                //列表项构造器
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    title: Text(repoList[index].repoName),
                    onTap: () {
                      onTapfunc(repoList[index]);
                    },
                    trailing: _ifAutoSaveIcon(repoList[index].isAutoSave),
                  );
                },
                //分割器构造器
                separatorBuilder: (BuildContext context, int index) {
                  return index % 2 == 0 ? divider1 : divider2;
                },
              );
            }
          } else {
            // 请求未结束，显示loading
            return const CircularProgressIndicator();
          }
        },
      ));
}
