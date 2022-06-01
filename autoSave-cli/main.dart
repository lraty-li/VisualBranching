import 'dart:convert';
import 'dart:io';

import 'autoSaverSet.dart';

final targetExeImageName = "delaytimer.exe";

Future<bool> checkRuning() async {
  final tasklistProc = await Process.start('tasklist',
      ["/NH", "/fi", 'IMAGENAME eq ${targetExeImageName}', "/fo", "csv"]);
  //TODO  decode?中文？
  // will error when transform the target not found
  final stream =
      tasklistProc.stdout.transform(utf8.decoder).transform(LineSplitter());
  var temp;
  try {
    temp = await stream.first;
    tasklistProc.kill();
    // print("${targetExeImageName} is running");
    print(temp);
    return true;
  } catch (e) {
    // print(e);
    print("no ${targetExeImageName} detected");
    return false;
  }
}

AutoSaveManag loadConfig() {
  //TODO 路径检查 Platform.resolvedExecutable 指向dart.exe 当 dart运行
  final repoDir = Directory(
      "${Directory.current.path}${Platform.pathSeparator}repos${Platform.pathSeparator}");
  AutoSaveManag manager = AutoSaveManag(instances: []);

  repoDir.listSync().forEach((element) {
    final repoIdName = element.path.split(Platform.pathSeparator).last;
    final repoConfig = json.decode(File(
            "${Directory.current.path}${Platform.pathSeparator}repos${Platform.pathSeparator}${repoIdName}${Platform.pathSeparator}${repoIdName}.json")
        .readAsStringSync())["config"];

    if (repoConfig["autoSave"]) {
      manager.instances.add(AutoSaveInstance(
          repoName: repoConfig["repoName"],
          repoIdName: repoIdName,
          comparionTable: Map.from(repoConfig["conparsionTable"]),
          autoSaveIntevalMins: repoConfig["autoSaveInterval"],
          autoSaveNum: repoConfig["autoSaveNums"]));
    }
  });
  return manager;
}

void main(List<String> args) async {
  //TODO 检查路径
  final isExist = await checkRuning();
  if (isExist) {
    print("已有 ${targetExeImageName} 运行中");
  } else {
    print("读取配置......");

    try {
      final manager = loadConfig();
      manager.instances.forEach((element) {
        print(element.repoName);
        element.autoSaveCTL = true;
      });
      print("配置读取完成，共 ${manager.instances.length}个实例:");

      print("全部启动自动备份,按r刷新配置读取(刷新期间暂停自动备份),e 启用全部自动备份, d 禁用全部自动备份, 按 q 退出 ,显示实例列表以及编号" );

      stdin.listen((event) {
        //TODO 大小写？
        switch (event[0]) {
          //"r"
          case (114):
            {
              //TODO handle reflash
              break;
            }
          //"e"
          case (101):
            {
              manager.setAll(true);
              break;
            }
          //"d"
          case (100):
            {
              manager.setAll(false);
              break;
            }
          //"q"
          case (113):
            {
              manager.setAll(false);
              exit(0);
            }
        }
      });
    } catch (e) {
      print(e);
      print("读取配置出错");
    }
  }

  print("main end");
}
