import 'package:flutter/material.dart';
import 'package:visual_branching/Repository/NewRepo/NewRepo.dart';
import 'package:visual_branching/Repository/OepnRepo.dart';
import 'package:visual_branching/Repository/RepoManage.dart';
import 'package:visual_branching/util/common.dart';

Widget repoMenuBuilder(BuildContext context) {
  return PopupMenuButton<repoOpt>(
    icon: Text("库"),
    //todo ? kToolbarHeight
    offset: Offset(0, kToolbarHeight / 2),
    onSelected: (repoOpt result) {
      _runOption(context, result);
    },
    itemBuilder: (BuildContext context) => <PopupMenuEntry<repoOpt>>[
      const PopupMenuItem<repoOpt>(
        value: repoOpt.openRepo,
        child: Text('打开'),
      ),
      const PopupMenuItem<repoOpt>(
        value: repoOpt.newRepo,
        child: Text('新建'),
      ),
      const PopupMenuItem<repoOpt>(
        value: repoOpt.managRepos,
        child: Text('管理'),
      ),
    ],
  );
}

void _runOption(BuildContext context, repoOpt opt) {
  switch (opt) {
    case repoOpt.openRepo:
      openRepoDialog(context);
      break;
    case repoOpt.newRepo:
      // create new repository
      newRepoDialog(context);
      break;
    case repoOpt.managRepos:
      repoManagDialog(context);
      break;
  }
}
