import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:visual_branching/Repository/NewRepo/fileChosing.dart';
import 'package:visual_branching/Repository/NewRepo/repoConfigModel.dart';
import 'package:visual_branching/Repository/NewRepo/repoOptions.dart';
import 'package:visual_branching/util/common.dart';
import 'package:visual_branching/util/models.dart';

void newRepoDialog(BuildContext context) {
  // RepoConfig repoConfig = RepoConfig();

  showDialog<String?>(
      context: context,
      builder: (context) {
        return ChangeNotifierProvider(
            create: (context) => RepoConfig(targetFilePaths: []),
            child: AlertDialog(
                title: Text("新建库"),
                actions: <Widget>[
                  Consumer<RepoConfig>(
                    builder: (context, repoConfig, child) {
                      return ElevatedButton(
                        onPressed: repoConfig.validated
                            ? () async {
                                // Navigator.of(context).pop();


                                //创建repo对象
                                Repo theCreatorRepo = await Repo.newRepo(
                                  repoConfig.repoName,
                                  repoConfig.autoSave,
                                  repoConfig.targetFilePaths,
                                  repoConfig.autoSaveInterval,
                                  repoConfig.autoSavesNums,
                                );

                                //创建一个手动备份作为新树根节点，并将会被设置为标头
                                await theCreatorRepo.newLeaf(
                                    NodeType.manually, "这是一个自动创建的手动备份",false);

                                if (repoConfig.autoSave) {
                                  //创建第一个自动备份

                                }

                                //生成json
                                theCreatorRepo.toJsonFile();
                                Navigator.of(context).pop();
                              }
                            : null,
                        child: Text("确认"),
                      );
                    },
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
                    height: MediaQuery.of(context).size.height * 0.5,
                    child: Flex(
                      direction: Axis.horizontal,
                      children: [
                        Consumer<RepoConfig>(
                            builder: (context, repoConfig, child) => Expanded(
                                  flex: 1,
                                  child: RepoOptions(configHandle: repoConfig),
                                )),
                        Consumer<RepoConfig>(
                            builder: (context, repoConfig, child) => Expanded(
                                  flex: 2,
                                  child: FileChosing(configHandle: repoConfig),
                                )),
                      ],
                    ))));
      });
}
