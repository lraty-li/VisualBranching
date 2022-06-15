import 'package:flutter/material.dart';

Widget popupMenuButtonBuilder<T>(
    String btnText,
    BuildContext context,
    List<T> optsEnumValues,
    List<String> optsEnumTexts,
    Function(BuildContext context, T type) onSeletedFunc) {
  return PopupMenuButton<T>(
      offset: const Offset(0, kToolbarHeight / 2),
      onSelected: (T result) {
        onSeletedFunc(context, result);
      },
      itemBuilder: (BuildContext context) => List<PopupMenuEntry<T>>.generate(
          optsEnumValues.length,
          (index) => PopupMenuItem<T>(
                value: optsEnumValues[index],
                child: Text(optsEnumTexts[index]),
              )),
      child: Container(
        margin: EdgeInsets.fromLTRB(15, 10, 15, 10),
        child: Text(btnText),
      ));
}

