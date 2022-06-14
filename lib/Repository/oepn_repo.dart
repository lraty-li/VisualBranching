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
            title: const Text(StringsCollection.openRepo),
            content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.5,
                height: MediaQuery.of(context).size.height * 0.6,
                child: FutureBuilder<List<Repo>>(
                  future: loadRepos(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      if (snapshot.hasError) {
                        // 请求失败，显示错误
                        return Text("Error: ${snapshot.error}");
                      } else {
                        // 请求成功，显示数据

                        return buildRepoList(snapshot.data as List<Repo>,
                            (repo) {
                          provider.removeAllOpenedRepo();
                          provider.addOpenRepo(repo);
                          Navigator.of(context).pop();
                        });
                      }
                    } else {
                      // 请求未结束，显示loading
                      return const CircularProgressIndicator();
                    }
                  },
                )),
          ),
        );
      });
}
