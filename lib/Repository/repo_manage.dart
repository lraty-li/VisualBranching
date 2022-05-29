import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:visual_branching/Repository/NewRepo/repo_config_model.dart';
import 'package:visual_branching/Repository/NewRepo/repo_options.dart';
import 'package:visual_branching/Repository/repos_list.dart';
import 'package:visual_branching/providers/main_status.dart';
import 'package:visual_branching/util/models.dart';

void repoManagDialog(BuildContext context) {
  showDialog<String?>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("库管理"),
          content: SizedBox(
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
                    // 请求成功，显示数据

                    return buildRepoList(snapshot.data as List<Repo>, (repo) {
                      Navigator.of(context).pop();
                      showDialog<String?>(
                          context: context,
                          builder: (context) {
                            return ChangeNotifierProvider(
                                create: (context) => RepoConfig(
                                    repoName: repo.repoName,
                                    autoSave: repo.isAutoSave,
                                    autoSaveInterval: repo.autoSaveIntevalMins,
                                    autoSavesNums: repo.autoSaveNum,
                                    //targetFilePaths is not editable here , simplly set a value to pass the validation
                                    targetFilePaths: const ["noNull"]),
                                child: AlertDialog(
                                    title: Text(repo.repoName),
                                    actions: <Widget>[
                                      Consumer<RepoConfig>(
                                        builder: (context, repoConfig, child) {
                                          return ElevatedButton(
                                            onPressed: repoConfig.validated
                                                ? () async {
                                                    // 修改配置

//todo 如果当前被修改repo正在被打开，虽然操作与配置无关，但是否要重新打开？
                                                    repo.alterRepo(
                                                        repoConfig.repoName,
                                                        repoConfig.autoSave,
                                                        repoConfig
                                                            .autoSaveInterval,
                                                        repoConfig
                                                            .autoSavesNums);
                                                    Navigator.of(context).pop();
                                                  }
                                                : null,
                                            child: const Text("确认修改"),
                                          );
                                        },
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text("取消"),
                                      ),
                                      ElevatedButton(
                                        style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all(
                                                    Colors.red)),
                                        onPressed: () {
                                          //todo impl
                                          //todo 关闭已打开 ()
                                          Provider.of<MainStatus>(context,
                                                  listen: false)
                                              .removeAllOpenedRepo();

                                          Repo.delRepo(repo);
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text("删除库"),
                                      ),
                                    ],
                                    content: SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.7,
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.5,
                                        child: Flex(
                                            direction: Axis.horizontal,
                                            children: [
                                              Consumer<RepoConfig>(
                                                  builder: (context, repoConfig,
                                                          child) =>
                                                      Expanded(
                                                        child: RepoOptions(
                                                            configHandle:
                                                                repoConfig),
                                                      )),
                                              Expanded(
                                                flex: 2,
                                                child: Flex(
                                                  direction: Axis.vertical,
                                                  children: [
                                                    const Text("已选择文件（不可修改)"),

                                                    Expanded(
                                                        child: ListView.builder(
                                                            itemCount: repo
                                                                .comparionTable
                                                                .keys
                                                                .length,
                                                            itemBuilder:
                                                                (BuildContext
                                                                        context,
                                                                    int index) {
                                                              //todo 检查平台？
                                                              final splitedStr = repo
                                                                  .comparionTable
                                                                  .values
                                                                  .elementAt(
                                                                      index)
                                                                  .split(Platform
                                                                      .pathSeparator);
                                                              return ListTile(
                                                                title: Text(
                                                                  "......${Platform.pathSeparator}${splitedStr[splitedStr.length - 2]}${Platform.pathSeparator}${splitedStr.last}",
                                                                  maxLines: 1,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .clip,
                                                                  softWrap:
                                                                      false,
                                                                ),
                                                              );
                                                            }))
                                                    //todo 不可更改，显示已选文件,
                                                  ],
                                                ),
                                              )
                                            ]))));
                          });
                    });
                  }
                } else {
                  // 请求未结束，显示loading
                  return CircularProgressIndicator();
                }
              },
            ),
          ),
        );
      });
}