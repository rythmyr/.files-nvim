set nocompatible

set runtimepath^=~/.local/nvim
let &packpath = &runtimepath

"================="
"plugin management"
"================="
call plug#begin('~/.local/nvim/plugged')
Plug 'editorconfig/editorconfig-vim'
Plug 'neoclide/coc.nvim', {'branch': 'release', 'do': ':CocInstall coc-eslint coc-tsserver coc-json coc-tslint-plugin coc-lists'}
Plug 'tpope/vim-surround'
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-dispatch'
Plug 'christoomey/vim-tmux-navigator'
Plug 'morhetz/gruvbox'
Plug 'jremmen/vim-ripgrep'
call plug#end()

"====================="
"universal vim options"
"====================="
colorscheme gruvbox "gruvbox colorscheme, available with plugin 'morhetz/gruvbox'
set hidden " can move away from buffer without saving first
set number " shows line number on current line (or all lines if relativenumber not set
set relativenumber " shows line numbers relative to current line
set numberwidth=5 " set the number of columns of the line numbers to 5 (4 digits + space)
set so=7 " leave at least 7 lines before/after cursor while scrolling up/down
set wildmenu " menu while tab completing commands
set noea " equalalways, no prevents windows from resizing when you close help/preview
set ar " autoread, if file is changed outside of vim and you switch to that buffer, automatically reload it
set bg=dark " better colors on a dark background
set cursorline " hilight the line with the cursor on it
set cursorcolumn " hilight the column with the cursor on it
set sw=4 " shift width, when tab is pressed, move in 4 spaces
set et " expandtab, use spaces instead of tabs when tab is pressed
set ts=4 " tabstop, display tab characters as 4 spaces
set incsearch " show matches as I search instead of after I press return
set listchars=tab:»\ ,extends:›,precedes:‹,nbsp:·,space:·,trail:·,eol:↲ " Used for showing whitespace, set to characters I don't type
set list " show invisible characters
set updatetime=500 " How long to wait after I type a character in normal mode to fire events
set signcolumn=yes " always show columns for git gutter, syntax errors, etc
set ignorecase " ignore case sensitivity in search by default
set smartcase " unless there's a capital letter
set shada+=n~/.local/nvim/viminfo " don't put stuff in the home directory
set timeoutlen=250 " 250 ms max between keypresses in a keybind
set splitbelow
set splitright
" for tab-completing filenames in vim commands, use recursive in current directory. forget /usr/includes. we don't need it.
" empty string = dir vim was opened in
" dot = directory current file is in
" ** = recursive, relative to dir vim was opened in
set path=,,.,**

" use purple as the background for showing search matches
hi Search ctermfg=13

augroup allBuffers
    autocmd!
    autocmd BufNewFile,BufRead * setlocal fo-=cro
augroup END

"=================="
"universal mappings"
"=================="

nnoremap <space> <nop>
let mapleader = " "
nnoremap <leader>ce :tabnew $MYVIMRC<cr>
nnoremap <leader>cr :source $MYVIMRC<cr>

nnoremap <leader>ss :syntax sync fromstart<cr>

" move lines up and down
noremap _ :normal ddkP<cr>
noremap - :normal ddp<cr>

" indenting using visual mode keeps selection
vnoremap < <gv
vnoremap > >gv

nnoremap Y y$

" complete with tab instead of <c-n> or <c-p>
inoremap <expr> <tab> pumvisible() ? "\<Down>" : "\<tab>"
inoremap <expr> <s-tab> pumvisible() ? "\<Up>" : "\<s-tab>"

nnoremap <leader><tab> za

" hilight last pasted content
nnoremap gp `[v`]

" turn off search hilighting when I enter insert mode
nnoremap i :noh<cr>i

" easier tab switching
nnoremap <leader>w <c-w>
nnoremap <leader>wt :tabn<cr>
nnoremap <leader>wr :tabN<cr>
nnoremap <leader>ws :split<cr>
nnoremap <leader>wv :vsplit<cr>

nnoremap n nzz
nnoremap N Nzz

"=================="
"universal commands"
"=================="

command! Scratch new<bar>resize 16<bar>setlocal buftype=nofile " open a scratch buffer and make it not huge
command! Term split<bar>resize 20<bar>normal <c-w>J:term<cr>
" start a terminal in the directory the current file is in
" the normal command doesn't work inside of the function for some reason
command! Lterm call s:localTerminal()<bar>normal <c-w>Ji
fun! s:localTerminal()
    let l:vim_dir = expand('%:p:h')
    let l:vim_current_dir = getcwd()
    split
    execute 'lcd ' . l:vim_dir
    resize 20
    terminal
    execute 'lcd ' . l:vim_current_dir
endfun

fun! s:files(bang)
    if (a:bang == '!' || !exists('s:files_buffer'))
        enew
        if (exists('s:files_buffer'))
            exec 'bw ' . s:files_buffer
        endif
        let s:files_buffer=bufnr("%")
        exec 'silent read !rg --files ' . get(g:, 'files_rg_args', '')
        %sort
        setlocal buftype=nofile
        setlocal bufhidden=hide
        setlocal nobuflisted
        setlocal noswapfile
        setlocal readonly
        setlocal nomodifiable
        nnoremap <buffer> <CR> gf
    else
        exec 'b ' . s:files_buffer
    endif
endfun

command! -bang -nargs=0 Find call s:files('<bang>')

"=========================="
"Language-specific settings"
"=========================="

"typescript stuff
fun! s:setTypescriptOptions()
    imap <buffer> <C-Space> <c-x><c-o>
    nmap <buffer> <leader>lu <Plug>(coc-references)
    nmap <buffer> <leader>ld <Plug>(coc-definition)
    nmap <buffer> <leader>lt <Plug>(coc-type-definition)
    nmap <buffer> <leader>lr <Plug>(coc-rename)
    nmap <buffer> <leader>lf <Plug>(coc-fix-current)
    nmap <buffer> <leader>ls :CocList -I symbols<cr>
    nnoremap <buffer> <leader>l/ I// <c-\><c-n>
    nnoremap <buffer> <leader>l? :s/\/\/ \?//<cr>:noh<cr>
    nnoremap <buffer> <leader>lz vi{zf
endfun
augroup typescript
    autocmd!
    autocmd FileType typescript call s:setTypescriptOptions()
augroup END

command! SetTypescriptOptions call s:setTypescriptOptions()
augroup javascript
    autocmd!
    autocmd FileType javascript call s:setTypescriptOptions()
augroup END

augroup javascriptreact
    autocmd!
    autocmd FileType javascriptreact call s:setTypescriptOptions()
augroup END

"c++ stuff
fun! s:setCppOptions()
    nmap <buffer> <leader>lu <Plug>(coc-references)
    nmap <buffer> <leader>ld <Plug>(coc-definition)
    nmap <buffer> <leader>lt <Plug>(coc-type-definition)
    nmap <buffer> <leader>lr <Plug>(coc-rename)
    nmap <buffer> <leader>lf <Plug>(coc-fix-current)
    nnoremap <buffer> <leader>l/ I// <c-\><c-n>
    nnoremap <buffer> <leader>l? :s/\/\/ \?//<cr>:noh<cr>
    nnoremap <buffer> <leader>lz vi{zf
endfun
augroup cpp
    autocmd!
    autocmd FileType cpp call s:setCppOptions()
augroup END

command! SetCppOptions call s:setCppOptions()


"html stuff
fun! s:setHtmlOptions()
    nnoremap <buffer> <leader>/ I<!--<c-\><c-n>A--><c-\><c-n>
    nnoremap <buffer> <leader>? :s/<!--\\|-->//g<cr>:noh<cr>
endfun
augroup html
    autocmd!
    autocmd FileType html call s:setHtmlOptions()
augroup END

command! SetHtmlOptions call s:setHtmlOptions()

"json stuff
fun! s:setJsonOptions()
    setlocal foldmethod=syntax
endfun
augroup json
    autocmd!
    autocmd FileType json call s:setJsonOptions()
augroup END

command! SetJsonOptions call s:setJsonOptions()

