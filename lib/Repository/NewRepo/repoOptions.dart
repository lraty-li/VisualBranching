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
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
            //todo 名字特殊字符？
            onChanged: ((value) => widget.configHandle.setRepoName(value)),
            decoration: InputDecoration(
                labelText: "库名称", errorText: _nameErrorText.value)),
        Row(
          children: [
            Text("开启自动保存"),

            // Builder(
            //   builder: (BuildContext context) {
            //     return ;
            //   },
            // ),
            Checkbox(
              value: widget.configHandle.autoSave,
              onChanged: (bool? value) {
                if (value != null) {
                  //todo 优化？
                  //todo 设置默认值（类初始化为60,40)  已添加，但缺乏显示
                  // (context as Element).markNeedsBuild();
                  setState(() {});
                  // widget.configHandle.autoSavesNums = value ? 60 : -1;
                  // widget.configHandle.autoSaveInterval = value ? 40 : -1;
                  widget.configHandle.autoSave = !widget.configHandle.autoSave;
                }
              },
            ),
          ],
        ),
        TextField(
          enabled: widget.configHandle.autoSave,
          keyboardType: TextInputType.number,
          onChanged: (value) {
            if (value.length > 0)
              widget.configHandle.autoSaveInterval = int.parse(value);
            setState(() {});
          },
          decoration: InputDecoration(
              labelText: "自动保存时间间隔(分钟)",
              errorText: _intervalErrTxt.value,
              //todo 可配置化（改为宏定义）
              hintText: "60"),
          inputFormatters: [
            NumericalRangeFormatter(max: 60, errTxtWarp: _intervalErrTxt)
          ],
        ),
        TextField(
          enabled: widget.configHandle.autoSave,
          keyboardType: TextInputType.number,
          onChanged: (value) {
            if (value.length > 0)
              widget.configHandle.autoSavesNums = int.parse(value);
            setState(() {});
          },
          decoration: InputDecoration(
              labelText: "自动保存个数上限",
              errorText: _saveNumErrTxt.value,
              hintText: "40"),
          inputFormatters: [
            NumericalRangeFormatter(max: 40, errTxtWarp: _saveNumErrTxt)
          ],
        )
      ],
    );
  }
}
