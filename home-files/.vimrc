" vim-plug
call plug#begin()

Plug 'git@github.com:avm99963/vim-jjdescription', { 'commit': 'c99bff42e7afff356514ae5b3f225665bf10b57c', }

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

" jj
autocmd FileType jjdescription setlocal textwidth=72
highlight def link jjdescriptionOverflow Error

" Makefile
autocmd FileType make set noexpandtab
