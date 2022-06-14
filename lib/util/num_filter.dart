import 'package:flutter/services.dart';
import 'package:visual_branching/util/class_wraper.dart';
import 'package:visual_branching/util/strings.dart';

class NumericalRangeFormatter extends TextInputFormatter {
  //自定义过滤器
  //TODO 最小值1
  final int max;
  ClassWraper errTxtWarp;
  String errTxtTemplate;
  NumericalRangeFormatter({required this.max, required this.errTxtWarp,this.errTxtTemplate=StringsCollection.maxValueAlarm});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text == '') {
      return newValue;
    }

    try {
      int.parse(newValue.text);
    } catch (e) {
      errTxtWarp.value = "";
      return oldValue;
    }
    int newValueInt = int.parse(newValue.text);
    if (newValueInt > max) {
      //TODO: 类型检查？
      errTxtWarp.value = "$errTxtTemplate : $max";
      TextEditingValue tempValue = TextEditingValue(
          selection: TextSelection.fromPosition(TextPosition(
              affinity: TextAffinity.downstream,
              offset: max.toString().length)),
          text: max.toString());
      return tempValue;
    } else {
      errTxtWarp.value = null;
      return newValue;
    }
  }
}
