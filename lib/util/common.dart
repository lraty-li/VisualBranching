enum NodeTapOpt {
  retrieve,
  newBranch,
  openFilePath,
  del,
}

enum RepoManagOpt {
  openRepo,
  newRepo,
  managRepos,
}
//todo extension 存储 字符串

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
