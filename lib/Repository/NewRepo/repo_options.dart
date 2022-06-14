import 'package:flutter/material.dart';
import 'package:visual_branching/Repository/NewRepo/repo_config_model.dart';
import 'package:visual_branching/util/class_wraper.dart';
import 'package:visual_branching/util/num_filter.dart';
import 'package:visual_branching/util/strings.dart';

class RepoOptions extends StatefulWidget {
  final RepoConfig configHandle;
  const RepoOptions({Key? key, required this.configHandle}) : super(key: key);

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
    super.initState();
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
                    ? StringsCollection.reposName
                    : widget.configHandle.repoName,
                labelText: StringsCollection.reposName,
                errorText: _nameErrorText.value)),
        const Text(StringsCollection.autoSaveIntroduce),
        Row(
          children: [
            const Text(StringsCollection.enAbleAutoSave),

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
            labelText: StringsCollection.autoSaveIntervalMins,
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
              widget.configHandle.setAutoSaveNums(int.parse(value));
            }
          },
          decoration: InputDecoration(
              labelText: StringsCollection.autoSaveNums,
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
