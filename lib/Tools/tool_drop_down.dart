import 'package:flutter/material.dart';
import 'package:visual_branching/Tools/create_shell_link_dialog.dart';
import 'package:visual_branching/util/builders.dart';
import 'package:visual_branching/util/common.dart';
import 'package:visual_branching/util/strings.dart';

Widget toolsMenuBuilder(BuildContext context) {
  return popupMenuButtonBuilder(StringsCollection.tools, context,
      ToolOpts.values, ToolOpts.values.map((e) => e.text).toList(), _runOption);
}

void _runOption(BuildContext context, ToolOpts opt) {
  switch (opt) {
    case ToolOpts.createShellLink:
      createShellLinkDialog(context);
      break;
  }
}
