import 'package:flutter/cupertino.dart';

class DataNode {
  ValueKey nodeKey;
  ValueKey parentNodeKey;
  List<ValueKey> childKeyss;
  String filePath;
  DateTime createdTime;
  bool canEdit;
  String annotation="";
  DataNode(this.nodeKey, this.filePath, this.createdTime,this.canEdit,this.parentNodeKey,this.childKeyss);
}

