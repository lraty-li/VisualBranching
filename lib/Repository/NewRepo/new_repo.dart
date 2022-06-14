import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:visual_branching/Repository/NewRepo/file_chosing.dart';
import 'package:visual_branching/Repository/NewRepo/repo_config_model.dart';
import 'package:visual_branching/Repository/NewRepo/repo_options.dart';
import 'package:visual_branching/providers/main_status.dart';
import 'package:visual_branching/util/common.dart';
import 'package:visual_branching/util/models.dart';
import 'package:visual_branching/util/strings.dart';
import 'package:window_manager/window_manager.dart';

void newRepoDialog(BuildContext context) {
  // RepoConfig repoConfig = RepoConfig();
  bool oldOnTop = Provider.of<MainStatus>(context, listen: false).alwaysOnTop;
  windowManager.setAlwaysOnTop(true);

  showDialog<String?>(
      context: context,
      builder: (context) {
        return WillPopScope(
          onWillPop: () {
            windowManager.setAlwaysOnTop(oldOnTop);
            Navigator.of(context).pop();
            return Future.value(false);
          },
          child: ChangeNotifierProvider(
              create: (context) => RepoConfig(targetFilePaths: []),
              child: AlertDialog(
                  title: Row(children: [
                    const Text(StringsCollection.createRepository),
                    Expanded(
                        child: DragToMoveArea(
                      child: Container(
                        height: 27,
                        color: const Color(0xFFD8D6D6),
                        child: const Center(
                          child: Text(StringsCollection.autoAlwaysOnTop),
                        ),
                      ),
                    ))
                  ]),
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
                                      NodeType.manually,
                                      StringsCollection.defaultAnnotation,
                                      false);

                                  if (repoConfig.autoSave) {
                                    //创建第一个自动备份

                                  }

                                  windowManager.setAlwaysOnTop(oldOnTop);
                                  Navigator.of(context).pop();
                                }
                              : null,
                          child: const Text(StringsCollection.confirmed),
                        );
                      },
                    ),
                    ElevatedButton(
                      onPressed: () {
                        windowManager.setAlwaysOnTop(oldOnTop);
                        Navigator.of(context).pop();
                      },
                      child: const Text(StringsCollection.cancel),
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
                                    child:
                                        RepoOptions(configHandle: repoConfig),
                                  )),
                          Consumer<RepoConfig>(
                              builder: (context, repoConfig, child) => Expanded(
                                    flex: 2,
                                    child:
                                        FileChosing(configHandle: repoConfig),
                                  )),
                        ],
                      )))),
        );
      });
}
