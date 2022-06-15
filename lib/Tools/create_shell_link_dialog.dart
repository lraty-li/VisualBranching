import 'dart:developer';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:visual_branching/Repository/repos_list.dart';
import 'package:visual_branching/Tools/shell_link_model.dart';
import 'package:visual_branching/util/custom_widgets.dart';
import 'package:visual_branching/util/strings.dart';
import 'dart:ffi';

// ignore: depend_on_referenced_packages
import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

//https://github.com/timsneath/win32/blob/main/example/shortcut.dart
void createShortcut(String path, String pathLink, String? description) {
  final shellLink = ShellLink.createInstance();
  final lpPath = path.toNativeUtf16();
  final lpPathLink = pathLink.toNativeUtf16();
  final lpDescription = description?.toNativeUtf16() ?? nullptr;
  // ignore: non_constant_identifier_names
  final ptrIID_IPersistFile = convertToCLSID(IID_IPersistFile);
  final ppf = calloc<COMObject>();

  try {
    shellLink.SetPath(lpPath);
    if (description != null) shellLink.SetDescription(lpDescription);

    final hr = shellLink.QueryInterface(ptrIID_IPersistFile, ppf.cast());
    if (SUCCEEDED(hr)) {
      IPersistFile(ppf)
        ..Save(lpPathLink, TRUE)
        ..Release();
    }
    shellLink.Release();
  } finally {
    free(lpPath);
    free(lpPathLink);
    if (lpDescription != nullptr) free(lpDescription);
    free(ptrIID_IPersistFile);
    free(ppf);
  }
}

void createShellLinkDialog(BuildContext pcontext) {
  showDialog(
      context: pcontext,
      builder: (context) {
        return ChangeNotifierProvider(
          create: (context) => ShellLnkConfig(),
          builder: (contextProvider, widget) {
            final stepsToCreateShellLnk = [
              Step(
                title: const Text(StringsCollection.chosingTargetExe),
                content: Container(
                  alignment: Alignment.centerLeft,
                  child: Column(children: [
                    Text("选择需要跟随启动自动保存的目标可执行文件，例如游戏"),
                    TextButton.icon(
                        onPressed: () async {
                          FilePicker.platform.pickFiles(
                              allowMultiple: false,
                              allowedExtensions: [".exe"]).then((result) {
                            if (result != null) {
                              if (result.paths.first != null) {
                                Provider.of<ShellLnkConfig>(contextProvider,
                                        listen: false)
                                    .setProperty(result.paths.first as String,
                                        ShellLnkConfigEnum.exePath);
                              }
                            }
                          });
                        },
                        icon: Icon(Icons.folder),
                        label: Text("选择文件"))
                  ]),
                ),
              ),
              Step(
                title: const Text(StringsCollection.chosingTargetRepo),
                content: Container(
                    alignment: Alignment.centerLeft,
                    child: Column(children: [
                      Text("选择对应需要跟随启动自动保存的目标仓库"),
                      TextButton.icon(
                          onPressed: () async {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text("选择仓库"),
                                    content: buildChosingRepoListView(context,
                                        (repo) {
                                      Provider.of<ShellLnkConfig>(
                                              contextProvider,
                                              listen: false)
                                          .setProperty(repo.repoIdName,
                                              ShellLnkConfigEnum.repoIdName);
                                      Navigator.of(context).pop();
                                    }),
                                  );
                                });
                          },
                          icon: const Icon(Icons.list),
                          label: Text("选择仓库"))
                    ])),
              ),
              Step(
                title: const Text(StringsCollection.chosingShellLnkSavingPath),
                content: Container(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                      onPressed: () async {
                        FilePicker.platform.getDirectoryPath().then((result) {
                          if (result != null) {
                            Provider.of<ShellLnkConfig>(contextProvider,
                                    listen: false)
                                .setProperty(result, ShellLnkConfigEnum.saveTo);
                          }
                        });
                      },
                      icon: const Icon(Icons.folder_open),
                      label: Text("选择仓库快捷方式保存位置(文件夹)")),
                ),
              )
            ];

            return AlertDialog(
              actions: <Widget>[
                Consumer<ShellLnkConfig>(
                  builder: (context, shellLnkConfig, child) {
                    return ElevatedButton(
                      onPressed: shellLnkConfig.validated
                          ? () async {
                              //TODO 字符串 autoSave 多语言/自定义？
                              //TODO .lnk platform check
                              createShortcut(
                                  shellLnkConfig.targetExePath,
                                  "${shellLnkConfig.shellLnkSaveToPath}${Platform.pathSeparator}AutoSave-${shellLnkConfig.targetExePath.split(Platform.pathSeparator).last}.lnk",
                                  null);
                              Navigator.of(context).pop();
                            }
                          : null,
                      child: const Text(StringsCollection.confirmed),
                    );
                  },
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(StringsCollection.cancel),
                ),
              ],
              content: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: StepperWidget(
                    stepsList: stepsToCreateShellLnk,
                    ctlBuilder: (context, detial) {
                      return Row(
                        children: [
                          TextButton.icon(
                              onPressed: detial.stepIndex ==
                                      stepsToCreateShellLnk.length - 1
                                  ? null
                                  //TODO onStepContinue be null?
                                  : () {
                                      // validation in here?
                                      detial.onStepContinue!();
                                    },
                              icon: Icon(Icons.arrow_downward),
                              label: Text(StringsCollection.nextStep)),
                          TextButton.icon(
                            onPressed: detial.stepIndex == 0
                                ? null
                                : detial.onStepCancel,
                            icon: Icon(Icons.arrow_upward),
                            label: Text(StringsCollection.prvStep),
                          ),
                        ],
                      );
                    },
                  )),
            );
          },
        );
      });
}
