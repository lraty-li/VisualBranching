import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:visual_branching/providers/MainStatus.dart';
import 'package:visual_branching/util/models.dart';

class SideListView extends StatelessWidget {
  const SideListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<MainStatus>(builder: (context, provider, child) {
      final targetRepo = provider.openedRepoList.first;
      final bool isAutoSave = targetRepo.isAutoSave;
      final List<Leaf> rootLeafs = targetRepo.rootLeafKeys
          .map(
            (e) => targetRepo.getLeafByKey(e),
          )
          .toList();
      return DefaultTabController(
        length: isAutoSave ? 3 : 2,
        child: Scaffold(
          appBar: PreferredSize(
            //72 or 46? check define of [Tab]
            //2 of default border?
            preferredSize: Size.fromHeight(48),
            child: AppBar(
              bottom: TabBar(
                tabs: [
                  Tab(text: '分支'),
                  Tab(text: '回收站'),
                  if (isAutoSave) Tab(text: '自动保存'),
                ],
              ),
            ),
          ),
          body: TabBarView(
            children: [
//todo rootleaf 也改为leaf类型？
              //显示节点头
              _buildListView(rootLeafs),

              //显示回收站
              _buildListView(targetRepo.leafRcyclBin),
              //显示自动保存
              if (isAutoSave) _buildListView(targetRepo.autoSaves),
            ],
          ),
        ),
      );
    });
  }
}

//todo impl ontap
Widget _buildListView(List<Leaf> theList) {
  return ListView.builder(
    //显示节点头
    itemCount: theList.length,
    itemBuilder: (BuildContext context, int index) {
      return ListTile(
          title: _buildBrefTile(theList[index].createdTime.toLocal().toString(),
              theList[index].annotation),
          //todo impl focus
          onTap: () => {print(index)});
    },
  );
}

Widget _buildBrefTile(String lT, String rD) {
  return SizedBox(
    height: 48,
    child: Stack(children: [
      Align(
        alignment: Alignment.topLeft,
        child: Text(
          lT,
          maxLines: 1,
        ),
      ),
      Align(
        alignment: Alignment.bottomRight,
        child: Text(
          rD,
          maxLines: 1,
        ),
      )
    ]),
  );
}
