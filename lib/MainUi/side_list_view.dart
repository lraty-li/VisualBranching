import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:visual_branching/providers/main_status.dart';
import 'package:visual_branching/util/common.dart';
import 'package:visual_branching/util/models.dart';
import 'package:visual_branching/util/strings.dart';

List<Leaf> loadJsonLeafs(String jsonFilePath) {
  //load the autoSaves.json
  final List<String> autoLeafKeys =
      List<String>.from(json.decode(File(jsonFilePath).readAsStringSync()));
  return autoLeafKeys.map((e) => Leaf(ValueKey(e), StringsCollection.autoSave)).toList();
}

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
      // 无法准确监听create event ，监听autoSaves.json
      final jsonFilePath =
          "${targetRepo.repoPath}${Platform.pathSeparator}autoSaves.json";

      List<Leaf> autoLeafs = loadJsonLeafs(jsonFilePath);

      return DefaultTabController(
        length: isAutoSave ? 3 : 2,
        child: Scaffold(
          appBar: PreferredSize(
            //TODO 72 or 46? check define of [Tab]
            //2 of default border?
            preferredSize: const Size.fromHeight(48),
            child: AppBar(
              bottom: TabBar(
                isScrollable: true,
                tabs: [
                  const Tab(text: StringsCollection.branch),
                  const Tab(text: StringsCollection.recycleBin),
                  if (isAutoSave) const Tab(text: StringsCollection.autoSave),
                ],
              ),
            ),
          ),
          body: TabBarView(
            children: [
              //显示节点头
              _buildListView(SideList.headOfBranch, rootLeafs, (index) {
                provider.focusToNode(rootLeafs[index].leafKey.value);
              }),

              //显示回收站
              _buildListView(SideList.recycleBin, targetRepo.leafRcyclBin,
                  (index) {
                //不复制， 移动leaf ,

                final targetLeaf = targetRepo.leafRcyclBin[index];

                targetRepo.retirveToLeaf(
                    targetLeaf.leafKey, LeafFrom.recycleBin);

                //在retriveTo 中，leaf已经从recycleBin中移到leafs
                provider.focusToNode(targetLeaf.leafKey.value);
              }),
              //显示自动保存
              if (isAutoSave)
                StreamBuilder(
                    stream: Directory(
                            "${targetRepo.repoPath}${Platform.pathSeparator}autoSaves")
                        .watch(),
                    //useless const to set init data
                    initialData: 0,
                    builder: (context, AsyncSnapshot snapshot) {
                      if (snapshot.hasError) {
                        //TODO 统一error widget
                        return const Center(child: Icon(Icons.error));
                      } else {
                        switch (snapshot.connectionState) {
                          case ConnectionState.none:
                            return const Center(
                                child: CircularProgressIndicator());
                          case ConnectionState.waiting:
                            {
                              break;
                            }
                          case ConnectionState.active:
                            {
                              //TODO 重复event导致更新
                              autoLeafs = loadJsonLeafs(jsonFilePath);
                              break;
                            }

                          case ConnectionState.done:
                            {
                              break;
                            }
                        }
                        return _buildListView(SideList.autoSave, autoLeafs,
                            (leafIndex) {
                          //非移动，而且“复制”一个完全一致的leaf
                          targetRepo.retirveToLeaf(
                              autoLeafs[leafIndex].leafKey, LeafFrom.autoSave);
                          provider
                              .focusToNode(autoLeafs[leafIndex].leafKey.value);
                        });
                      }
                    })
            ],
          ),
        ),
      );
    });
  }
}


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
                            value: index,
                            child: const Text(StringsCollection.retriveToLeaf),
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
          // title: _buildBrefTile(theList[index].createdTime.toLocal().toString(),
          title: _buildBrefTile(
              theList[index].createdTime.toString(), theList[index].annotation),
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
