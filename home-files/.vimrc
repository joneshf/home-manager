" vim-plug
call plug#begin()

Plug 'git@github.com:tpope/vim-surround.git', { 'commit': '3d188ed2113431cf8dac77be61b842acb64433d9', }

call plug#end()

" Personal settings

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
