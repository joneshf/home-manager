{ writeShellScriptBin
}:
writeShellScriptBin
  "git-restack"
  ''
    exec git -c sequence.editor='restack edit' rebase --interactive "$@"
  ''
