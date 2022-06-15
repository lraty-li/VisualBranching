import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:visual_branching/Repository/repos_list.dart';
import 'package:visual_branching/providers/main_status.dart';
import 'package:visual_branching/util/models.dart';
import 'package:visual_branching/util/strings.dart';

void openRepoDialog(BuildContext context) {
  showDialog<String?>(
      context: context,
      builder: (context) {
        return Consumer<MainStatus>(
          builder: (context, provider, child) => AlertDialog(
            title: const Text(StringsCollection.openRepository),
            content: buildChosingRepoListView(context, (repo) {
              provider.removeAllOpenedRepo();
              provider.addOpenRepo(repo);
              Navigator.of(context).pop();
            }),
          ),
        );
      });
}
