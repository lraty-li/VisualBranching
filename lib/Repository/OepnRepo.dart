import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:visual_branching/Repository/ReposList.dart';
import 'package:visual_branching/providers/MainStatus.dart';
import 'package:visual_branching/util/models.dart';

void openRepoDialog(BuildContext context) {
  showDialog<String?>(
      context: context,
      builder: (context) {
        return Consumer<MainStatus>(
            builder: (context, provider, child) => AlertDialog(
                  title: Text("打开库"),
                  content: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.5,
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: loadRepos((repo) {
                      provider.removeAll();
                      provider.add(repo);
                      Navigator.of(context).pop();
                    }),
                  ),
                ));
      });
}
