import 'package:bot_toast/bot_toast.dart';

class StringsCollection {
  static const backupToHeader = "备份到标头";
  static const newCreatedLeaf = "新建节点";
  static const retriveToHeader = "回退到标头";
  static const cleanRecycleBin = "清空回收站";
  static const clnRcyleBinConfirm = "确认清空回收站？";
  static const clnRcyleBinAlert = "不会移动到系统回收站，清空后无法恢复。";

  static const autoSave = "自动保存";
  static const branch = "分支";
  static const recycleBin = "回收站";
  static const retriveToLeaf = "回退到该节点";

  static const setting = "设置";
  static const settingInfo = "这是未完成版本,你可以点击确认前往github页面寻找更新\n$projGithubUrl";
  static const projGithubUrl = "https://github.com/lraty-li/VisualBranching";

  static const dragFileToHere = "也可以直接拖拽到这里";
  static const startChoingFile = "选择文件";
  static const clearChosenFIles = "清空选择";

  static const createRepository = "新建库";
  static const autoAlwaysOnTop = "已自动置顶窗口，此处可拖动窗口";
  static const defaultAnnotation = "默认备注";
  static const confirmed = "确认";
  static const cancel = "取消";

  static const reposName = "库名称";
  static const autoSaveIntroduce = "自动保存不在此软件运行\n修改配置后请手动刷新自动保存\n";
  static const enAbleAutoSave = "开启自动保存";
  static const autoSaveIntervalMins = "自动保存时间间隔(分钟)";
  static const autoSaveNums = "自动保存个数上限";

  static const openRepository = "打开库";

  static const repoManagement = "库管理";
  static const applyAlter = "应用修改";
  static const delRepoWarningQuery = "确认删除库？";
  static const delRepoWarningDeatil = "不会移动到系统回收站，删除后无法恢复。请刷新自动保存";
  static const delRepo = "删除库";
  static const chosenFilesUnChangeAble = "已选择文件（不可修改)";

  static const newBranchFromLeaf = "由节点新建分支";
  static const openLeafDir = "打开节点文件路径";
  static const alterAnnotation = "修改备注";
  static const inputNewAnnoation = "输入新备注";
  static const delLeaf = "删除该节点";

  static const repository = "库";
  static const open = "打开";
  static const create = "新建";
  static const management = "管理";

  static const maxValueAlarm = "最大值为:";

  static const copiedFromAutoSave = "由自动保存复制";
  static const restoreFormRecycleBin = "由回收站还原:";
  static const backupWhenTargetOverWrite = "发生覆盖时的备份";
  static const targeFilesDeled = "目标文件被删除";

  static const tools = "工具";
  static const createShellLink = "创建快捷方式";

  static const chosingTargetExe = "选择目标exe";
  static const chosingTargetRepo = "选择跟随启动自动保存的库";
  static const chosingShellLnkSavingPath = "选择快捷方式保存位置";

  static const nextStep = "下一步";
  static const prvStep = "上一步";

  static const chosingFile="选择文件";

  static String chosenFileCounting(int count) {
    return "已选择$count个文件";
  }
}
