import 'package:flutter/material.dart';
import 'package:visual_branching/Repository/NewRepo/NewRepo.dart';
import 'package:visual_branching/Repository/OepnRepo.dart';
import 'package:visual_branching/Repository/RepoManage.dart';
import 'package:visual_branching/util/common.dart';

Widget repoMenuBuilder(BuildContext context) {
  return PopupMenuButton<RepoManagOpt>(
    icon: Text("库"),
    //todo ? kToolbarHeight
    offset: Offset(0, kToolbarHeight / 2),
    onSelected: (RepoManagOpt result) {
      _runOption(context, result);
    },
    itemBuilder: (BuildContext context) => <PopupMenuEntry<RepoManagOpt>>[
      const PopupMenuItem<RepoManagOpt>(
        value: RepoManagOpt.openRepo,
        child: Text('打开'),
      ),
      const PopupMenuItem<RepoManagOpt>(
        value: RepoManagOpt.newRepo,
        child: Text('新建'),
      ),
      const PopupMenuItem<RepoManagOpt>(
        value: RepoManagOpt.managRepos,
        child: Text('管理'),
      ),
    ],
  );
}

void _runOption(BuildContext context, RepoManagOpt opt) {
  switch (opt) {
    case RepoManagOpt.openRepo:
      openRepoDialog(context);
      break;
    case RepoManagOpt.newRepo:
      // create new repository
      newRepoDialog(context);
      break;
    case RepoManagOpt.managRepos:
      repoManagDialog(context);
      break;
  }
}
