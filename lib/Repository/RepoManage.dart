import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:visual_branching/Repository/NewRepo/repoConfigModel.dart';
import 'package:visual_branching/Repository/NewRepo/repoOptions.dart';
import 'package:visual_branching/Repository/ReposList.dart';
import 'package:visual_branching/util/models.dart';

void repoManagDialog(BuildContext context) {
  showDialog<String?>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("库管理"),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.5,
            height: MediaQuery.of(context).size.height * 0.6,
            child: loadRepos((repo) {
              //todo add repo detail and del？

              //打开新建repo界面，根据收到参数修改现有repo
              //如何禁用文件选择？

              showDialog<String?>(
                  context: context,
                  builder: (context) {
                    return ChangeNotifierProvider(
                        create: (context) => RepoConfig(
                            repoName: repo.repoName,
                            autoSave: repo.isAutoSave,
                            autoSaveInterval: repo.autoSaveIntevalMins,
                            autoSavesNums: repo.autoSaveNum,
                            targetFilePaths: []),
                        child: AlertDialog(
                            title: Text("${repo.repoName}"),
                            actions: <Widget>[
                              Consumer<RepoConfig>(
                                builder: (context, repoConfig, child) {
                                  return ElevatedButton(
                                    onPressed: repoConfig.validated
                                        ? () async {
                                            // 修改配置
                                            repo.repoName = repoConfig.repoName;
                                            repo.isAutoSave =
                                                repoConfig.autoSave;
                                            repo.autoSaveIntevalMins =
                                                repoConfig.autoSaveInterval;
                                            repo.autoSaveNum =
                                                repoConfig.autoSavesNums;

                                            //生成json
                                            repo.toJsonFile();
                                            Navigator.of(context).pop();
                                          }
                                        : null,
                                    child: Text("确认修改"),
                                  );
                                },
                              ),
                              ElevatedButton(
                                style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all(Colors.red)),
                                onPressed: () {
                                  //todo impl
                                  // Navigator.of(context).pop();
                                },
                                child: Text("删除库"),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text("取消"),
                              ),
                            ],
                            content: SizedBox(
                                width: MediaQuery.of(context).size.width * 0.7,
                                height:
                                    MediaQuery.of(context).size.height * 0.5,
                                child: Flex(
                                  direction: Axis.horizontal,
                                  children: [
                                    Consumer<RepoConfig>(
                                        builder: (context, repoConfig, child) =>
                                            Expanded(
                                              flex: 1,
                                              child: RepoOptions(
                                                  configHandle: repoConfig),
                                            )),
                                    //todo 不可更改，显示已选文件,
                                  ],
                                ))));
                  });
            }),
          ),
        );
      });
}

managRepo(Repo theRepo) {
  //todo impl
}
