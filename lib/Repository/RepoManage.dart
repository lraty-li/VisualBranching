import 'package:flutter/material.dart';
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
            child: loadRepos((repo){
              //todo add repo detail and del？
            }),
          ),
        );
      });
}

managRepo(Repo theRepo){
  //todo impl
}