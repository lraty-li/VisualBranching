import 'package:flutter/material.dart';
import 'package:visual_branching/Repository/NewRepo/new_repo.dart';
import 'package:visual_branching/Repository/oepn_repo.dart';
import 'package:visual_branching/Repository/repo_manage.dart';
import 'package:visual_branching/util/builders.dart';
import 'package:visual_branching/util/common.dart';
import 'package:visual_branching/util/strings.dart';

Widget repoMenuBuilder(BuildContext context) {
  //TODO 自行showmenu
  return popupMenuButtonBuilder(
      StringsCollection.repository,
      context,
      RepoManagOpt.values,
      RepoManagOpt.values.map((e) => e.text).toList(),
      _runOption);
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
