import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:visual_branching/Repository/NewRepo/repoConfigModel.dart';
import 'package:visual_branching/util/classWraper.dart';
import 'package:visual_branching/util/numFilter.dart';

class RepoOptions extends StatefulWidget {
  final RepoConfig configHandle;
  const RepoOptions({Key? key, required RepoConfig this.configHandle})
      : super(key: key);

  @override
  State<RepoOptions> createState() => RRepoOptionsState();
}

class RRepoOptionsState extends State<RepoOptions> {
  final ClassWraper<String?> _nameErrorText = ClassWraper<String?>(value: null);
  final ClassWraper<String?> _intervalErrTxt =
      ClassWraper<String?>(value: null);
  final ClassWraper<String?> _saveNumErrTxt = ClassWraper<String?>(value: null);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    inspect(widget.configHandle);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
            //todo 名字特殊字符？
            onChanged: ((value) => widget.configHandle.setRepoName(value)),
            decoration: InputDecoration(
                hintText: widget.configHandle.repoName.isEmpty
                    ? "库名称"
                    : widget.configHandle.repoName,
                labelText: "库名称",
                errorText: _nameErrorText.value)),
        Row(
          children: [
            Text("开启自动保存"),

            // Builder(
            //   builder: (BuildContext context) {
            // (context as Element).markNeedsBuild();
            //     return ;
            //   },
            // ),
            Checkbox(
              value: widget.configHandle.autoSave,
              onChanged: (bool? value) {
                if (value != null) {
                  //todo 优化？
                  widget.configHandle.setIfAutoSave(value);
                }
              },
            ),
          ],
        ),
        TextField(
          enabled: widget.configHandle.autoSave,
          keyboardType: TextInputType.number,
          onChanged: (value) {
            if (value.isNotEmpty) {
              widget.configHandle.setAutoSaveIntervel(int.parse(value));
            }
          },
          decoration: InputDecoration(
            labelText: "自动保存时间间隔(分钟)",
            errorText: _intervalErrTxt.value,
            //todo 可配置化（“60” 改为宏定义）
            hintText: widget.configHandle.autoSaveInterval < 0
                ? "-1"
                : widget.configHandle.autoSaveInterval.toString(),
          ),
          inputFormatters: [
            NumericalRangeFormatter(max: 60, errTxtWarp: _intervalErrTxt)
          ],
        ),
        TextField(
          enabled: widget.configHandle.autoSave,
          keyboardType: TextInputType.number,
          onChanged: (value) {
            if (value.isNotEmpty) {
              widget.configHandle..setAutoSaveNums(int.parse(value));
            }
          },
          decoration: InputDecoration(
              labelText: "自动保存个数上限",
              errorText: _saveNumErrTxt.value,
              hintText: widget.configHandle.autoSavesNums < 0
                  ? "-1"
                  : widget.configHandle.autoSavesNums.toString()),
          inputFormatters: [
            NumericalRangeFormatter(max: 40, errTxtWarp: _saveNumErrTxt)
          ],
        )
      ],
    );
  }
}
