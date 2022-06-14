import 'package:flutter/material.dart';
import 'package:visual_branching/Repository/NewRepo/new_repo.dart';
import 'package:visual_branching/Repository/oepn_repo.dart';
import 'package:visual_branching/Repository/repo_manage.dart';
import 'package:visual_branching/util/common.dart';
import 'package:visual_branching/util/strings.dart';

Widget repoMenuBuilder(BuildContext context) {
  //TODO 自行showmenu
  return PopupMenuButton<RepoManagOpt>(
    icon: const Text(StringsCollection.repository),
    //todo ? kToolbarHeight
    offset: const Offset(0, kToolbarHeight / 2),
    onSelected: (RepoManagOpt result) {
      _runOption(context, result);
    },
    itemBuilder: (BuildContext context) => <PopupMenuEntry<RepoManagOpt>>[
      const PopupMenuItem<RepoManagOpt>(
        value: RepoManagOpt.openRepo,
        child: Text(StringsCollection.open),
      ),
      const PopupMenuItem<RepoManagOpt>(
        value: RepoManagOpt.newRepo,
        child: Text(StringsCollection.create),
      ),
      const PopupMenuItem<RepoManagOpt>(
        value: RepoManagOpt.managRepos,
        child: Text(StringsCollection.management),
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
