// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

import 'autoSaverSet.dart';

Future<bool> checkRuning(String targetExeImageName) async {
  final tasklistProc = await Process.start('tasklist',
      ["/NH", "/fi", 'IMAGENAME eq $targetExeImageName', "/fo", "csv"]);
  //TODO  decode?中文？

  // will error when transform the target not found
  final stream = tasklistProc.stdout
      .transform(utf8.decoder)
      .transform(const LineSplitter());
  try {
    //获取pid，排除自身pid
    var hasNotSame = false;
    await for (var line in stream) {
      print("ownpid:${pid} | ${line}");
      final elems =
          line.split(',').map((elem) => elem.replaceAll('"', '')).toList();
      if (pid != int.parse(elems[1])) {
        print("${elems[0]} pid: $elems[1] ");
        hasNotSame = true;
      }
    }
    if (hasNotSame) {
      return true;
    }
    tasklistProc.kill();

    // print("${targetExeImageName} is running");
    // print(temp);
    return false;
  } catch (e) {
    // print(e);
    print("no $targetExeImageName runing");
    return false;
  }
}

AutoSaveManag loadConfig() {
  // Platform.resolvedExecutable 指向dart.exe 当 dart运行
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
  manager.setAllautoSave(true);
  showMsg("配置读取完成，共 ${manager.instances.length}个实例,全部启动自动备份:");
  return manager;
}

void showDelayExitMsg(String msg) {
  //show error mostly
  print("$msg,即将退出...");
  Future.delayed(const Duration(seconds: 15)).then((value) => exit(0));
}

void showHelpMsg() {
  print("===[帮助 - 输入字母并回车,区分大小写]===");
  print("""
      [r]刷新配置读取(刷新期间取消自动备份)
      [e] 启用/禁用全部自动备份
      [i] 显示运行中的备份
      [v] 开关或关闭全部备份消息
      [h] 显示此条帮助消息
      [q] 退出""");
}

void showMsg(String msg) {
  print("[info] ${DateTime.now()} : $msg");
}
