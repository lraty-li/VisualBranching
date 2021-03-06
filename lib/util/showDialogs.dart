import 'package:flutter/material.dart';
import 'package:visual_branching/util/strings.dart';

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
              child: const Text(StringsCollection.confirmed),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(StringsCollection.cancel),
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
          title: const Text("选择"),
          children: [SimpleDialogOption(onPressed: (() => {}))],
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
              child: const Text(StringsCollection.confirmed),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text(StringsCollection.cancel),
            ),
          ],
        );
      });
}

showLoadingDialog(BuildContext context) {
  AlertDialog alert = AlertDialog(
    content: Row(
      children: const [
        CircularProgressIndicator(),
        // Container(margin: EdgeInsets.only(left: 7),child:Text("Loading..." )),
      ],
    ),
  );
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
