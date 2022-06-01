import 'package:flutter/material.dart';
import 'package:visual_branching/Repository/NewRepo/new_repo.dart';
import 'package:visual_branching/Repository/oepn_repo.dart';
import 'package:visual_branching/Repository/repo_manage.dart';
import 'package:visual_branching/util/common.dart';

Widget repoMenuBuilder(BuildContext context) {
  //TODO 自行showmenu
  return PopupMenuButton<RepoManagOpt>(
    icon: const Text("库"),
    //todo ? kToolbarHeight
    offset: const Offset(0, kToolbarHeight / 2),
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
