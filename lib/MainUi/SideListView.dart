import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:visual_branching/providers/MainStatus.dart';
import 'package:visual_branching/util/common.dart';
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
            (e) => targetRepo.getLeafByKey(e, LeafFrom.leafs),
          )
          .toList();
      return DefaultTabController(
        length: isAutoSave ? 3 : 2,
        child: Scaffold(
          appBar: PreferredSize(
            //todo 72 or 46? check define of [Tab]
            //2 of default border?
            preferredSize: Size.fromHeight(48),
            child: AppBar(
              bottom: TabBar(
                isScrollable: true,
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
              //显示节点头
              _buildListView(SideList.headOfBranch, rootLeafs, (index) {
                provider.focusToNode(rootLeafs[index].leafKey);
              }),

              //显示回收站
              _buildListView(SideList.recycleBin, targetRepo.leafRcyclBin,
                  (index) {
                //不复制， 移动leaf ,
                //todo 是否修改备注？
                targetRepo.leafRcyclBin[index].annotation =
                    "由回收站还原:${targetRepo.leafRcyclBin[index].annotation}";
                targetRepo.retirveToLeaf(targetRepo.leafRcyclBin[index].leafKey,
                    LeafFrom.recycleBin);
                //todo 除了聚焦标头，其他都是聚焦到header。
                provider.focusToNode(
                    ValueKey(targetRepo.leafRcyclBin[index].leafKey.value));
                provider.updateVoidCall();
              }),
              //显示自动保存
              if (isAutoSave)
                _buildListView(SideList.recycleBin, targetRepo.autoSaves,
                    (index) {
                  //todo copy the leaf
                  targetRepo.retirveToLeaf(
                      targetRepo.autoSaves[index].leafKey, LeafFrom.autoSave);
                }),
            ],
          ),
        ),
      );
    });
  }
}

//todo impl ontap
Widget _buildListView(SideList tapFrom, List<Leaf> theList,
    void Function(int leafIndex) onTapfunc) {
  Offset tapPosition;
  return ListView.builder(
    //显示节点头

    itemCount: theList.length,
    itemBuilder: (BuildContext context, int index) {
      return InkWell(
        onTapDown: (details) {
          tapPosition = details.globalPosition;

          final RenderObject? overlay =
              Overlay.of(context)?.context.findRenderObject();

          switch (tapFrom) {
            case SideList.headOfBranch:
              {
                onTapfunc(index);
                break;
              }
            default:
              // case SideList.recycleBin:
              // case SideList.autoSave:
              {
                showMenu(
                        context: context,
                        items: <PopupMenuEntry<int>>[
                          PopupMenuItem(
                            child: Text("回退到节点"),
                            value: index,
                          )
                        ],

                        //基本是右对齐
                        position: RelativeRect.fromRect(
                            tapPosition &
                                const Size(
                                    1, 1), // smaller rect, the touch area
                            Offset.zero &
                                overlay!.semanticBounds
                                    .size // Bigger rect, the entire screen
                            ))
                    .then(
                  (value) {
                    if (value != null) {
                      onTapfunc(value);
                    }
                  },
                );
              }
          }
        },
        child: ListTile(
          title: _buildBrefTile(theList[index].createdTime.toLocal().toString(),
              theList[index].annotation),
        ),
      );
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
