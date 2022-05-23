import 'package:flutter/material.dart';

void nodeOnTap(BuildContext context, ValueKey nodeKey) {
  showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: Text("选择"),
          children: [
            SimpleDialogOption(
                child: Text("回档到该节点"), onPressed: (() => {print("Line35")})),
            SimpleDialogOption(
                child: Text("设为标头"), onPressed: (() => {print("Line35")})),
            SimpleDialogOption(
                child: Text("由节点新建分支"), onPressed: (() => {print("Line35")})),
            SimpleDialogOption(
                child: Text("打开节点文件路径"), onPressed: (() => {print("Line35")})),
            SimpleDialogOption(
                child: Text("删除该节点"), onPressed: (() => {print("Line35")})),
          ],
        );
      });
}
