import 'package:flutter/material.dart';

Future<String?> strDialog(BuildContext context, String title, annotation) {
  final myController = TextEditingController();
  return showDialog<String?>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            decoration: InputDecoration(hintText: annotation),
            controller: myController,
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(myController.text);
              },
              child: Text("确认"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("取消"),
            ),
          ],
        );
      });
}

Future<int?> choseDialog(BuildContext context) {
  return showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: Text("选择"),
          children: [
            SimpleDialogOption(onPressed: (() => {print("Line35")}))
          ],
        );
      });
}

Future<bool?> confirmDialog(
    BuildContext context, String title, String hintText) {
  return showDialog<bool?>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(hintText),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text("确认"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text("取消"),
            ),
          ],
        );
      });
}

Future<String?> reposShower(BuildContext context, String key,
    List<ValueKey> repoKeys, VoidCallback ontap) {
  return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
            title: Text("选择库"),
            content: Container(
              height: 300.0, // Change as per your requirement
              width: 300.0, // Change as per your requirement
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: repoKeys.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    //todo 根据valuekey 查找 库名称
                    title: Text('根据valuekey 查找 库名称'),
                    onTap: ontap,
                    //todo pop chosen tile
                  );
                },
              ),
            ));
      });
}
