{
  crane,
  installShellFiles,
  runCommand,
  ...
}:
runCommand "crane-completions"
  {
    nativeBuildInputs = [
      crane
      installShellFiles
    ];
  }
  ''
    installShellCompletion \
        --cmd crane \
        --bash <(crane completion bash) \
        --fish <(crane completion fish) \
        --zsh <(crane completion zsh)
  ''
