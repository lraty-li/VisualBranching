import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:visual_branching/util/strings.dart';

class StepperWidget extends StatefulWidget {
  const StepperWidget({Key? key, required this.stepsList, this.ctlBuilder})
      : super(key: key);
  final List<Step> stepsList;
  final Widget Function(BuildContext, ControlsDetails)? ctlBuilder;
  @override
  State<StepperWidget> createState() => _StepperWidgetState();
}

class _StepperWidgetState extends State<StepperWidget> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Stepper(
      controlsBuilder: widget.ctlBuilder,
      currentStep: _index,
      onStepCancel: () {
        if (_index > 0) {
          setState(() {
            _index -= 1;
          });
        }
      },
      onStepContinue: () {
        if (_index < widget.stepsList.length - 1) {
          setState(() {
            _index += 1;
          });
        }
      },
      onStepTapped: (int index) {
        setState(() {
          _index = index;
        });
      },
      steps: widget.stepsList,
    );
  }
}

class SingleFileChosingBtn extends StatefulWidget {
  const SingleFileChosingBtn({Key? key, this.acceptedExtension})
      : super(key: key);
  final List<String>? acceptedExtension;
  @override
  State<SingleFileChosingBtn> createState() => _SingleFileChosingBtnState();
}

class _SingleFileChosingBtnState extends State<SingleFileChosingBtn> {
  @override
  Widget build(BuildContext context) {
    //TODO 显示已选文件名
    return TextButton.icon(
        onPressed: () async {
          FilePickerResult? result = await FilePicker.platform.pickFiles(
              allowMultiple: false,
              allowedExtensions: widget.acceptedExtension);
        },
        icon: Icon(Icons.folder),
        label: Text(StringsCollection.chosingFile));
  }
}
