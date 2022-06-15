import 'package:visual_branching/util/strings.dart';

enum NodeTapOpt {
  retrieve,
  newBranch,
  openFilePath,
  del,
}

extension NodeTapOptText on NodeTapOpt {
  String get text {
    switch (this) {
      case NodeTapOpt.retrieve:
        return StringsCollection.retriveToLeaf;
      case NodeTapOpt.newBranch:
        return StringsCollection.newBranchFromLeaf;
      case NodeTapOpt.openFilePath:
        return StringsCollection.openLeafDir;
      case NodeTapOpt.del:
        return StringsCollection.delLeaf;
      default:
        //TODO 宏定义该文本
        return "undefine NodeTapOptText";
    }
  }
}

enum RepoManagOpt {
  openRepo,
  newRepo,
  managRepos,
}

extension RepoManagOptsStr on RepoManagOpt {
  String get text {
    switch (this) {
      case RepoManagOpt.openRepo:
        return StringsCollection.openRepository;
      case RepoManagOpt.newRepo:
        return StringsCollection.createRepository;
      case RepoManagOpt.managRepos:
        return StringsCollection.repoManagement;
      default:
        return "undefine RepoManagOptsStr";
    }
  }
}

enum ToolOpts { createShellLink }

extension ToolOptsStr on ToolOpts {
  String get text {
    switch (this) {
      case ToolOpts.createShellLink:
        return StringsCollection.createShellLink;

      default:
        return "undefine ToolOpts";
    }
  }
}

enum NodeType { manually, automatically }

enum LeafFrom { leafs, recycleBin, autoSave }

enum CopyDirection {
  target2Leaf,
  target2recycle,
  target2AutoSave,
  leaf2Target,
  leafs2recycle,
  recycle2Leafs,
  autoSave2Leafs
}

enum SideList {
  headOfBranch,
  recycleBin,
  autoSave,
}
