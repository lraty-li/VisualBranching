// ignore_for_file: avoid_print

import 'dart:io';

import 'autoSaverSet.dart';
import 'util.dart';

void main(List<String> args) async {
  //TODO 检查路径
  //查找visual_branching.exe
  if (!File("visual_branching.exe").existsSync()) {
    print("应放置到 visual_branching.exe 同级目录下");
    showDelayExitMsg("即将退出:");
  }
  final autoSaveEXEName =
      Platform.resolvedExecutable.split(Platform.pathSeparator).last;

  bool verboseTogle = true;
  bool autoSaveTogle = true;
  AutoSaveManag manager = AutoSaveManag(instances: []);

  final isExist = await checkRuning(autoSaveEXEName);
  if (isExist) {
    showDelayExitMsg("已有 $autoSaveEXEName 运行中");
  } else {
    print("读取配置......");
    try {
      manager = loadConfig();

      showHelpMsg();

      stdin.listen((event) {
        //TODO 大小写？
        switch (event[0]) {
          //"r"
          case (114):
            {
              showMsg("关闭全部运行中备份");
              manager.setAllautoSave(false);
              manager.cancelAllTimer();
              showMsg("重新读取备份配置");
              manager = loadConfig();
              showMsg("刷新备份设置完成");
              break;
            }
          //"e"
          case (101):
            {
              autoSaveTogle = !autoSaveTogle;
              manager.setAllautoSave(autoSaveTogle);
              showMsg("已${autoSaveTogle ? "启用" : "禁用"}全部自动备份");
              break;
            }
          // //"d"
          // case (100):
          //   {
          //     manager.setAllautoSave(false);
          //     showMsg("已禁用全部自动备份");
          //     break;
          //   }
          //"i"
          case (105):
            {
              showMsg("运行中的自动备份:");
              print("实例名称; 自动保存间隔; 自动保存个数上限;");
              for (var element in manager.instances) {
                print(
                    "${element.repoName}; ${element.autoSaveIntevalMins}分钟; ${element.autoSaveNum}个");
              }

              break;
            }
          //"v"
          case (118):
            {
              verboseTogle = !verboseTogle;
              manager.setAllverbose(verboseTogle);
              showMsg("${verboseTogle ? "开启" : "关闭"}备份消息");
              break;
            }
          //"q"
          case (113):
            {
              showMsg("即将退出...");
              manager.setAllautoSave(false);
              manager.cancelAllTimer();
              Future.delayed(const Duration(seconds: 3))
                  .then((value) => exit(0));
              break;
            }
          default:
            {
              showHelpMsg();
            }
        }
      });
    } catch (e) {
      print(e);
      showDelayExitMsg("读取配置出错");
    }
  }
}
