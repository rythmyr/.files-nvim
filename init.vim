set nocompatible

set runtimepath^=~/.local/nvim
let &packpath = &runtimepath

"================="
"plugin management"
"================="
call plug#begin('~/.local/nvim/plugged')
Plug 'editorconfig/editorconfig-vim'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'tpope/vim-surround'
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter', {'branch': 'main'}
Plug 'tpope/vim-dispatch'
Plug 'christoomey/vim-tmux-navigator'
Plug 'morhetz/gruvbox'
Plug 'jremmen/vim-ripgrep'
Plug 'MaxMEllon/vim-jsx-pretty'
call plug#end()

"CoC extensions
let g:coc_global_extensions = [
    \ 'coc-eslint',
    \ 'coc-tsserver',
    \ 'coc-json',
    \ 'coc-tslint-plugin',
    \ 'coc-lists',
    \ 'coc-omnisharp',
    \ 'coc-prettier'
    \]


let g:gruvbox_termcolors=16
"====================="
"universal vim options"
"====================="
colorscheme gruvbox "gruvbox colorscheme, available with plugin 'morhetz/gruvbox'
set hidden " can move away from buffer without saving first
set number " shows line number on current line (or all lines if relativenumber not set)
" set relativenumber " shows line numbers relative to current line
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
set listchars=tab:»\ ,extends:›,precedes:‹,nbsp:·,space:·,trail:·,eol:$ " Used for showing whitespace, set to characters I don't type
set list " show invisible characters
set updatetime=500 " How long to wait after I type a character in normal mode to fire events
set signcolumn=yes " always show columns for git gutter, syntax errors, etc
set ignorecase " ignore case sensitivity in search by default
set smartcase " unless there's a capital letter
set shada+=n~/.local/nvim/viminfo " don't put stuff in the home directory
set timeoutlen=250 " 250 ms max between keypresses in a keybind
set splitbelow
set splitright
set sessionoptions=curdir,tabpages,winsize

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

nnoremap <leader>y "+y
nnoremap <leader>p "+p
nnoremap <leader>P "+P
nnoremap <leader>ss :syntax sync fromstart<cr>

" indenting using visual mode keeps selection
vnoremap < <gv
vnoremap > >gv

nnoremap Y y$

" complete with tab instead of <c-n> or <c-p>
inoremap <expr> <tab> pumvisible() ? "\<C-n>" : "\<tab>"
inoremap <expr> <s-tab> pumvisible() ? "\<C-p>" : "\<s-tab>"

" toggle folds
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

" windows visually glitches a lot, this is the only way I've found to fix it afterward easily
" <C-n> is same as j/down arrow normally (in normal mode), <C-p> I'm guessing is the same as k/up arrow
nnoremap <C-n> :mode<cr>

"=================="
"universal commands"
"=================="

command! Term split<bar>resize 20<bar>normal <c-w>J:term<cr>
" start a terminal in the directory the current file is in
" the normal command doesn't work inside of the function for some reason
command! Lterm call s:localTerminal()<bar>normal <c-w>Ji
fun! s:localTerminal()
    let l:vim_dir = expand('%:p:h')
    let l:vim_current_dir = getcwd()
    tab split
    execute 'lcd ' . l:vim_dir
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
        exec 'silent read !rg --files ' . escape(get(g:, 'files_rg_args', '.'), '!')
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
    exec 'CocList -I --ignore-case lines'
endfun

command! -bang -nargs=0 F call s:files('<bang>')
command! -bang -nargs=0 Find call s:files('<bang>')
command! -bang -nargs=0 Tf tab split<bar>call s:files('<bang>')
command! -bang -nargs=0 Tabfind tab split<bar>call s:files('<bang>')
command! -bang -nargs=0 Sf split<bar>call s:files('<bang>')
command! -bang -nargs=0 Splitfind split<bar>call s:files('<bang>')
command! -bang -nargs=0 Vf vertical split<bar>call s:files('<bang>')
command! -bang -nargs=0 Vertfind vertical split<bar>call s:files('<bang>')

nnoremap <leader>ff :Find<cr>
nnoremap <leader>ft :Tabfind<cr>
nnoremap <leader>fs :Splitfind<cr>
nnoremap <leader>fv :Vertfind<cr>

fun! s:scratch(mods)
    exec a:mods . ' new scratch'
    setlocal buftype=nofile
    setlocal buftype=nofile
    setlocal bufhidden=hide
    setlocal nobuflisted
endfun

command! Scratch call s:scratch('<mods>')

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
    setlocal path=.,src,node_modules,
    setlocal suffixesadd=.js,.ts,.jsx,.tsx
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

augroup typescriptreact
    autocmd!
    autocmd FileType typescriptreact call s:setTypescriptOptions()
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

fun! s:setCSharpOptions()
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
augroup csharp
    autocmd!
    autocmd FileType cs call s:setCSharpOptions()
augroup END

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

