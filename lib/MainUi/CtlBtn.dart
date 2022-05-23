import 'package:flutter/material.dart';

class CtlBtn extends StatelessWidget {
  const CtlBtn({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      _styledBtn(
        text: "备份到标头",
      ),
      //todo 回退逻辑
      _styledBtn(
        text: "回退到标头",
      ),
    ]);
  }
}

class _styledBtn extends StatelessWidget {
  final String text;

  // _styledBtn(this.text);
  const _styledBtn({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
        child:
            ElevatedButton(onPressed: () => {print("hi")}, child: Text(text)));
  }
}
