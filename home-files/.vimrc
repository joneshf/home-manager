set number
syntax enable

set autoindent
set smartindent

set expandtab
set shiftwidth=4
set smarttab
set tabstop=4

" git
autocmd FileType gitcommit set textwidth=72
highlight def link gitcommitOverflow Error

" Makefile
autocmd FileType make set noexpandtab
