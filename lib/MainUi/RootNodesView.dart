import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:visual_branching/providers/OpenedRepos.dart';

class RootsListView extends StatelessWidget {
  const RootsListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<OpenedRepos>(builder: (context, provider, child) {
      if (provider.openedRepoList.length > 0) {
        return ListView.builder(
          itemCount: provider.openedRepoList.first.rootLeafKeys.length,
          //列表项构造器
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
                title: Text(
                    provider.openedRepoList.first.rootLeafKeys[index].value),
                //todo impl focus
                onTap: () => {print(index)});
          },
        );
      }
      return ListView();
    });
    ;
  }
}
