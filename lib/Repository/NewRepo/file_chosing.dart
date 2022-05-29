import 'dart:io';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:visual_branching/Repository/NewRepo/repo_config_model.dart';

// List<XFile> chosenFileList = [];

class FileChosing extends StatefulWidget {
  final RepoConfig configHandle;
  const FileChosing({Key? key, required this.configHandle}) : super(key: key);

  @override
  State<FileChosing> createState() => _FileChosingState();
}

class _FileChosingState extends State<FileChosing> {
  bool _ondragging = false;

  @override
  Widget build(BuildContext context) {
    return Flex(direction: Axis.vertical, children: [
      Text("已选择${widget.configHandle.targetFilePaths.length}个文件"),
      DropTarget(
        onDragEntered: (detail) {
          _ondragging = true;
          setState(() {});
        },
        onDragExited: (detail) {
          _ondragging = false;
          setState(() {});
        },
        onDragDone: (detail) {
          for (final newfile in detail.files) {
            bool noSame = true;
            if (FileSystemEntity.isDirectorySync(newfile.path)) {
              //添加目录下所有文件
              Directory tempDirecotry = Directory(newfile.path);
              List<FileSystemEntity> entityList =
                  tempDirecotry.listSync(recursive: true, followLinks: false);
              for (var element in entityList) {
                if (element is File) {
                  //检查重复

                  for (var chosenFile in widget.configHandle.targetFilePaths) {
                    if (chosenFile == element.path) {
                      noSame = false;
                      break;
                    }
                  }
                  //todo batchupdate？
                  if (noSame) widget.configHandle.addTarget(element.path);
                }
              }
            } else {
              //不是文件夹

              for (var file in widget.configHandle.targetFilePaths) {
                if (file == newfile.path) {
                  noSame = false;
                  break;
                }
              }
              if (noSame) widget.configHandle.addTarget(newfile.path);
            }
          }

          setState(() {});
        },
        child: Expanded(
          child: Container(
            color: _ondragging ? Colors.blue.withOpacity(0.4) : Colors.black26,
            child: Stack(
              children: [
                if (widget.configHandle.targetFilePaths.isEmpty)
                  const Center(child: Text("也可以直接拖拽到这里"))
                else
                  ListView.builder(
                      itemCount: widget.configHandle.targetFilePaths.length,
                      itemBuilder: (BuildContext context, int index) {
                        //todo 检查平台？
                        var splitedStr = widget
                            .configHandle.targetFilePaths[index]
                            .split(Platform.pathSeparator);
                        return ListTile(
                          title: Text(
                            "......${Platform.pathSeparator}${splitedStr[splitedStr.length - 2]}${Platform.pathSeparator}${splitedStr.last}",
                            maxLines: 1,
                            overflow: TextOverflow.clip,
                            softWrap: false,
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              widget.configHandle.delTarget(index);
                              setState(() {});
                            },
                          ),
                        );
                      })
              ],
            ),
          ),
        ),
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ElevatedButton(
              onPressed: () async {
                FilePickerResult? result =
                    await FilePicker.platform.pickFiles(allowMultiple: true);

                if (result != null) {
                  bool noSame = true;
                  List<File> files =
                      result.paths.map((path) => File(path!)).toList();
                  for (var newfile in files) {
                    for (var file in widget.configHandle.targetFilePaths) {
                      if (file == newfile.path) {
                        noSame = false;
                        break;
                      }
                    }
                    if (noSame) {
                      widget.configHandle.addTarget(newfile.path);
                    }
                  }
                  setState(() {});
                } else {
                  // User canceled the picker
                }
              },
              child: const Text("选择...")),
          ElevatedButton(
              onPressed: () => {
                    setState(() {
                      widget.configHandle.clearAllTarget();
                    })
                  },
              child: const Text("清空选择"))
        ],
      )
    ]);
  }
}
