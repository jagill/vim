set nocompatible	" don't try to be vi (This must be first)

" Pathogen config. This allows us a vim 'package maintainer'
" If this is not running, you need to run 
" $HOME/.vim/bin/update_plugins.py --help
" to see how to install pathogen and other plugins.

filetype off 
execute pathogen#infect()
filetype plugin indent on

"""""""""""""""""""""""""""""""""""""""""""""""""""
" Problems to overcome:
" 1. Cut/paste working smoothly -- Done?
" 2. Set up Cscope in a helpful way
" 4. Make "ge" equiv in camelcasemotion

"""""""""""""""""""""""""""""""""""""""""""""""""""
" settings
"""""""""""""""""""""""""""""""""""""""""""""""""""


set hidden          " Allow buffers to be hidden without writing, and remember their marks.
set autowrite       " Autosave when I use tags, switch buffers, etc
set ruler		    " Show the cursor position all the time
set number          " show line numbers
set laststatus=2    " Show statusline even when there is only one buffer open
set hlsearch        " highlight search results 
set incsearch		" do incremental searching
set ignorecase smartcase        " make searching case-insensitive, unless there's a capital letter in it
set backspace=indent,eol,start  " allow backspacing over everything in insert mode 
set backup		    " keep a backup file
set history=50		" keep 50 lines of command line history
set showcmd		    " display incomplete commands
set shiftwidth=4	" 4 space indents
set expandtab		" don't use tab characters
set softtabstop=4	" make the tab key move 4 spaces
set tabstop=4	    " tabs show as 4 spaces. Makes them more obvious.
set title           " Show title of file in terminal mode
set shortmess=filnxtToOI     " Suppress many of the "Press RETURN to continue"
set visualbell      " Don't audibly beep
set wildmenu        " Show all possible word completions
" set wildmode=list:longest     " Only complete up to points of ambiguity
set wildmode=list:longest,full  " You can also toggle through the matches by tab
"Ignore these files when completing names and in Explorer
set wildignore=.svn,CVS,.git,*.o,*.a,*.class,*.mo,*.la,*.so,*.obj,*.swp,*.jpg,*.png,*.xpm,*.gif,*~,*.pyc,*.pyo
let &tags=$projectHome . '/.tags'  " ctags file location
set path=$projectHome/**  " set the project root as the base directory for find command
set grepprg=ack\ --type-add\ jsp=.vm\ --ignore-dir=bin\ --ignore-dir=build " use ack not grep for searching
set listchars=eol:$,tab:>-,trail:~,extends:>,precedes:< "Show invisble characters with :set list

set mouse=a 		" this enables vim mouse handling, and mucks up cut-paste from putty
set mouseshape=i:beam

set clipboard=unnamed   " Default for all unnamed yank/etc operations to store in system clipboard

"set diffopt+=iwhite    "Ignore whitespace when diffing

" Switch syntax highlighting on, when the terminal has colors
if &t_Co > 2 || has("gui_running")
  syntax on
  colorscheme osx_like
endif

" Set the status bar color depending on mode
if version >= 700
  au InsertEnter * hi StatusLine term=reverse,italic ctermfg=4 ctermbg=3 guifg=Yellow guibg=DarkBlue
  au InsertLeave * hi StatusLine term=NONE ctermfg=None ctermbg=None guifg=#829db9 guibg=#333333
endif

"set guicursor=n-v-c:block-Cursor
"set guicursor+=i:ver30-iCursor-blinkwait300-blinkon200-blinkoff150
"
" Set a red cursor in insert mode, and a black cursor otherwise.
" Works at least for xterm and rxvt terminals.
" Does not work for gnome terminal, konsole, xfce4-terminal.
" This should work for the mac terminal (which says &term=xterm), but it
" hasn't yet. Ubuntu has worked fine.
"if &term =~ "xterm\\|rxvt"
  ":silent !echo -ne "\033]12;black\007"
  "let &t_SI = "\033]12;red\007"
  "let &t_EI = "\033]12;black\007"
  "autocmd VimLeave * :!echo -ne "\033]12;black\007"
"endif

"""""""""""""""""""""""""""""""""""""""""""""""""""
" commands
"""""""""""""""""""""""""""""""""""""""""""""""""""
" Press Space to turn off highlighting and clear any message already
" displayed.
nnoremap <silent> <Space> :nohlsearch<Bar>:echo<CR>

"allow deleting selection without updating the clipboard (yank buffer)
noremap x "_x
vnoremap x "_x
noremap X "_X
vnoremap X "_X

map go o<esc>k
map gO O<esc>j

" Abbreviations
" Alias %% to the directory of the current file.
cabbr <expr> %% expand('%:p:h') 

" make ZZ work how I expect with multiple buffers
noremap  ZZ :wqa<CR>

" Edit the .vimrc file
map <Leader>v :sp $HOME/.vimrc<CR>
" Reload .vimrc
map <silent> <Leader>V :source $HOME/.vimrc<CR>:filetype detect<CR>:exe ":echo 'vimrc reloaded'"<CR>

"FIXME: This fails horrible if you aren't on a word.
map <F1> :grep <cword><CR>

map <F5> :w<CR>:exec ":!" . &makeprg . " %"<CR>

" Copy current register into clipboard in mac
if has("macunix")
  nmap <silent> <Leader>p :call system('echo ' . shellescape(getreg()) . ' \| pbcopy')<CR> 
endif

map <Leader>1 :b1<CR>
map <Leader>2 :b2<CR>
map <Leader>3 :b3<CR>
map <Leader>4 :b4<CR>
map <Leader>5 :b5<CR>
map <Leader>6 :b6<CR>
map <Leader>7 :b7<CR>
map <Leader>8 :b8<CR>
map <Leader>9 :b9<CR>

"if has("macunix")
"  let s:uname = substitute(system("uname"),"\n","","g")
"  if s:uname == "Darwin"
"    "Do mac stuff
"  elseif s:uname == "Linux"
"    "Do linux stuff
"  endif
"endif

"Command to sudo write current file.
":w !sudo tee %

" Convenient command to see the difference between the current buffer and the
" file it was loaded from, thus the changes you made.
command! DiffOrig vert new | set bt=nofile | r # | 0d_ | diffthis | wincmd p | diffthis


"""""""""""""""""""""""""""""""""""""""""""""""""""""
" Movements
"""""""""""""""""""""""""""""""""""""""""""""""""""""
" Switch ` and '
noremap ' `
noremap ` '


" Map CamelCaseMotion to something that doesn't use ,
"map <Leader>ccw <Plug>CamelCaseMotion_w
"map <Leader>ccb <Plug>CamelCaseMotion_b
"map <Leader>cce <Plug>CamelCaseMotion_e

"MacVim, using the mac keys
if has("macunix") && has("gui_running")
  " Add nicer HIG movements when in mac and gui (ie, macvim)
  " This made some shift movements highlight nicely, but messed up the normal
  " visual mode.
  "let macvim_hig_shift_movement = 1

  " Disable the .gvimrc movements in macvim so we can define our own
  let macvim_skip_cmd_opt_movement=1


  "Shift movements
  "map   <S-Left>      <Leader>ccb
  "map!  <S-Left>      <C-o><Leader>ccb
  "map   <S-Right>     <Leader>ccw
  "map!  <S-Right>     <C-o><Leader>ccw
  map   <S-Left>      <Plug>CamelCaseMotion_b
  map!  <S-Left>      <C-o><Plug>CamelCaseMotion_b
  map   <S-Right>     <Plug>CamelCaseMotion_w
  map!  <S-Right>     <C-o><Plug>CamelCaseMotion_w
  map   <S-Up>        :call NextIndent(0, 0, 1, 1)<CR>
  map!  <S-Up>        <C-o>:call NextIndent(0, 0, 1, 1)<CR>
  map   <S-Down>      :call NextIndent(0, 1, 1, 1)<CR>
  map!  <S-Down>      <C-o>:call NextIndent(0, 1, 1, 1)<CR>
  "map e <Plug>CamelCaseMotion_e
  "Control movements
  no   <C-Left>       b
  no!  <C-Left>       <C-o>b
  no   <C-Right>      w
  no!  <C-Right>      <C-o>w
  no   <C-Up>         {
  ino  <C-Up>         <C-o>{
  no   <C-Down>       }
  ino  <C-Down>       <C-o>}
  "Option movements
  no   <M-Left>       B
  no!  <M-Left>       <C-o>B
  no   <M-Right>      W
  no!  <M-Right>      <C-o>W
  no   <M-Up>         <C-b>
  ino  <M-Up>         <C-o><C-b>
  no   <M-Down>       <C-f>
  ino  <M-Down>       <C-o><C-f>
  no   <M-Tab>        <C-w>w
  ino  <M-Tab>        <C-o><C-w>w
  no   <M-S-Tab>      <C-w>W
  ino  <M-S-Tab>      <C-o><C-w>W
  "Command movements
  no   <D-Left>       <Home>
  no!  <D-Left>       <Home>
  no   <D-Right>      <End>
  no!  <D-Right>      <End>
  no   <D-Up>         <C-Home>
  ino  <D-Up>         <C-Home>
  no   <D-Down>       <C-End>
  ino  <D-Down>       <C-End>
  "Deletions
  map  <S-BS>         d<S-Left>
  map! <S-BS>         <C-o>d<S-Left>
  map  <S-Del>        d<S-Right>
  map! <S-Del>        <C-o>d<S-Right>
  map  <C-BS>         d<C-Left>
  map! <C-BS>         <C-o>d<C-Left>
  map  <C-Del>        d<C-Right>
  map! <C-Del>        <C-o>d<C-Right>
  map  <M-BS>         d<M-Left>
  map! <M-BS>         <C-o>d<M-Left>
  map  <M-Del>        d<M-Right>
  map! <M-Del>        <C-o>d<M-Right>
  map  <D-BS>         d<D-Left>
  map! <D-BS>         <C-o>d<D-Left>
  map  <D-Del>        d<D-Right>
  map! <D-Del>        <C-o>d<D-Right>
  map  <C-S-BS>       diw
  map! <C-S-BS>       <C-o>diw
  map  <M-S-BS>       diW
  map! <M-S-BS>       <C-o>diW
endif

" Normal OSX
" S-UP,DOWN: Highlight up,down
" S-RIGHT,LEFT: Highlight right,left
" C-UP,DOWN: Scroll PgUp,Down, don't move cursor
" C-RIGHT,LEFT: Beginning/end of line
" M-UP,DOWN: Up/down, at beginning/end of line
" M-RIGHT,LEFT: word forward,back
" D-UP,DOWN: Beginning,end of document
" D-RIGHT,LEFT: Beginning,end of line
" BS: Delete previous char
" Del: Delete next char
" C-BS: Delete single character
" C-Del: Nothing
" M-BS: Delete to previous beginning of word
" M-Del: Delete to next end of word
" D-BS: Delete to beginning of line
" D-Del (D-Del?): Nothing

"""""""""""""""""""""""""""""""""""""""""""""""""""
" modules configuration
"""""""""""""""""""""""""""""""""""""""""""""""""""
if has("cscope")
    cscope add $projectHome . '/.cscope.out'
    "Source standard mappings for cscope
    "source $HOME/.vim/cscope_maps.vim
endif

" minibuf
let g:miniBufExplSortBy = "mru" " Sort buffers by Most Recently Used
let g:miniBufExplCycleArround = 1 " Cycle through buffers
map <C-TAB> :MBEbb<cr> " Backward in MRU order
map <S-C-TAB> :MBEbf<cr> " Forward in MRU order
map <Leader>be <Plug>MBEOpen<cr>  " Open and/or goto Explorer
map <Leader>bc <Plug>MBEClose<cr> " Close the Explorer if it's open
map <Leader>bt <Plug>MBEToggle<cr> " Toggle the Explorer window open and closed.
map <Leader>bm <Plug>MBEMarkCurrent<cr> " Mark current buffer


"Map NERDTree commands
noremap <silent> <Leader>nt :NERDTreeToggle<CR>
noremap <silent> <Leader>nf :NERDTreeFind<CR>

" Trying out tagbar instead of taglist
map <silent> <Leader>o :TagbarToggle<CR>

" TagList
" Show a taglist in the sidebar (ie, outline)
let Tlist_Exit_OnlyWindow = 1     " exit if taglist is last window open
let Tlist_Show_One_File = 1       " Only show tags for current buffer
let Tlist_Enable_Fold_Column = 0  " no fold column (only showing one file)
let Tlist_GainFocus_On_ToggleOpen=1

" LookupFile
" F5 conflicts with other mappings, remap it to \f
let g:LookupFile_DisableDefaultMap=1
nmap <silent> <Leader>f <Plug>LookupFile
" From below, <F12> regenerates .filenametags
let g:LookupFile_TagExpr = string($projectHome.'/.filenametags')

"if has("gui_macvim")
"  macmenu &File.New\ Tab key=<nop>
"  map <D-t> :CommandT<CR>
"endif

" CheckSyntax
" F5 mapping conflicts with ours, remap it
noremap <Leader>S :CheckSyntax<CR>

" NERDCommenter
:map <silent> <Leader>ct :call NERDComment(1, 'toggle')<CR>
"let g:NERDCustomDelimiters = {
    "\ 'handlebars': { 'left': '<!--', 'right': '-->' }
"\ }

"alternate.txt
"Set up alternates that handle objc/objcpp
let g:alternateExtensions_h = "c,cpp,cxx,cc,m,mm"
let g:alternateExtensions_m = "h"
let g:alternateExtensions_mm = "h"
let g:alternateExtensions_html = "coffee,js"
let g:alternateExtensions_coffee = "html"

" TaskList
" override default
map <Leader>t <Plug>TaskList

" clipbrd
" override default
"nmap <silent> <Leader>clip <Plug>ClipBrdOpen

" Fugitive
"Set statusline to include git branch
"set statusline=%<%f\ %h%m%r%{fugitive#statusline()}%=%-14.(%l,%c%V%)\ %P

" CamelCaseMotion
"omap iw <Plug>CamelCaseMotion_iw
"xmap iw <Plug>CamelCaseMotion_iw
"omap ib <Plug>CamelCaseMotion_ib
"xmap ib <Plug>CamelCaseMotion_ib
"omap ie <Plug>CamelCaseMotion_ie
"xmap ie <Plug>CamelCaseMotion_ie
 
" Togglewords words
nmap <Leader>g :ToggleWord<CR>
let g:toggle_words_dict = {'python': [['if', 'elif', 'else']]}
 
" Syntastic
let g:syntastic_auto_loc_list = 1
let g:syntastic_coffeescript_coffeelist_args = "-f $HOME/.coffee-config.json"
let g:syntastic_html_checkers=['tidy']
let g:syntastic_html_tidy_blocklevel_tags=['template']

" Yankstack
call yankstack#setup()
"Make Y work consistently with C and D
"This is go after the setup, because it redefines it.
nmap Y y$
 
" indent-guides
"let g:indent_guides_auto_colors = 0
"autocmd VimEnter,Colorscheme * :hi IndentGuidesOdd  guibg=red   ctermbg=3
"autocmd VimEnter,Colorscheme * :hi IndentGuidesEven guibg=green ctermbg=4

"""""""""""""""""""""""""""""""""""""""""""""""""""""
" Neocomplete
"""""""""""""""""""""""""""""""""""""""""""""""""""""

"Placing the line set complete=.,w,b,u,t,i in your ~/.vimrc file allows you to automatically complete any class, method, or field name by pressing [Ctrl]N while in insert mode. Successive presses of [Ctrl]N bring up the next matches. When you see the tag you want, just continue typing the rest of your source code. 
set complete=.,w,b,u,t,i
set completeopt+=longest

" Disable AutoComplPop.
let g:acp_enableAtStartup = 0
" Use neocomplete.
let g:neocomplete#enable_at_startup = 1
" Use smartcase.
let g:neocomplete#enable_smart_case = 1
" Set minimum syntax keyword length.
let g:neocomplete#sources#syntax#min_keyword_length = 3
let g:neocomplete#lock_buffer_name_pattern = '\*ku\*'

" Define dictionary.
let g:neocomplete#sources#dictionary#dictionaries = {
    \ 'default' : '',
    \ 'vimshell' : $HOME.'/.vimshell_hist',
    \ 'scheme' : $HOME.'/.gosh_completions'
        \ }

" Define keyword.
if !exists('g:neocomplete#keyword_patterns')
    let g:neocomplete#keyword_patterns = {}
endif
let g:neocomplete#keyword_patterns['default'] = '\h\w*'

" Plugin key-mappings.
inoremap <expr><C-g>     neocomplete#undo_completion()
inoremap <expr><C-l>     neocomplete#complete_common_string()

" Recommended key-mappings.
" <CR>: close popup and save indent.
inoremap <silent> <CR> <C-r>=<SID>my_cr_function()<CR>
function! s:my_cr_function()
  return neocomplete#smart_close_popup() . "\<CR>"
  " For no inserting <CR> key.
  "return pumvisible() ? neocomplete#close_popup() : "\<CR>"
endfunction
" <TAB>: completion.
inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"
" <C-h>, <BS>: close popup and delete backword char.
inoremap <expr><C-h> neocomplete#smart_close_popup()."\<C-h>"
inoremap <expr><BS> neocomplete#smart_close_popup()."\<C-h>"
inoremap <expr><C-y>  neocomplete#close_popup()
inoremap <expr><C-e>  neocomplete#cancel_popup()
" Close popup by <Space>.
"inoremap <expr><Space> pumvisible() ? neocomplete#close_popup() : "\<Space>"

" For cursor moving in insert mode(Not recommended)
"inoremap <expr><Left>  neocomplete#close_popup() . "\<Left>"
"inoremap <expr><Right> neocomplete#close_popup() . "\<Right>"
"inoremap <expr><Up>    neocomplete#close_popup() . "\<Up>"
"inoremap <expr><Down>  neocomplete#close_popup() . "\<Down>"
" Or set this.
"let g:neocomplete#enable_cursor_hold_i = 1
" Or set this.
"let g:neocomplete#enable_insert_char_pre = 1

" AutoComplPop like behavior.
"let g:neocomplete#enable_auto_select = 1

" Shell like behavior(not recommended).
"set completeopt+=longest
"let g:neocomplete#enable_auto_select = 1
"let g:neocomplete#disable_auto_complete = 1
"inoremap <expr><TAB>  pumvisible() ? "\<Down>" : "\<C-x>\<C-u>"

" Enable omni completion.
autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags

" Enable heavy omni completion.
if !exists('g:neocomplete#sources#omni#input_patterns')
  let g:neocomplete#sources#omni#input_patterns = {}
endif
"let g:neocomplete#sources#omni#input_patterns.php = '[^. \t]->\h\w*\|\h\w*::'
"let g:neocomplete#sources#omni#input_patterns.c = '[^.[:digit:] *\t]\%(\.\|->\)'
"let g:neocomplete#sources#omni#input_patterns.cpp = '[^.[:digit:] *\t]\%(\.\|->\)\|\h\w*::'

" For perlomni.vim setting.
" https://github.com/c9s/perlomni.vim
"let g:neocomplete#sources#omni#input_patterns.perl = '\h\w*->\h\w*\|\h\w*::'
"""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Autocommands
"""""""""""""""""""""""""""""""""""""""""""""""""""""""
if has("autocmd") 

  " Put these in an autocmd group, so that we can delete them easily.
  augroup vimrcEx   " define group

  " remove all commands for the current group
  au!

  " use filetype=velocity on .vm files 
  autocmd BufRead,BufNewFile *.vm set filetype=velocity
  " use filetype=handlebars on .html files 
  "autocmd BufRead,BufNewFile *.html set filetype=handlebars
  " use filetype=python on .psp files 
  autocmd BufRead,BufNewFile *.psp set filetype=python
  " use filetype=objcpp on .mm files 
  autocmd BufRead,BufNewFile *.mm set filetype=objcpp
  autocmd BufRead,BufNewFile *.json set filetype=json foldmethod=syntax
  autocmd BufRead,BufNewFile *.md set filetype=markdown
  au BufRead,BufNewFile *.twig set filetype=htmljinja

  "PYTHON
  " Check syntax and run python script.
  autocmd FileType python set makeprg=python\ -c\ \"import\ py_compile,sys;\ sys.stderr=sys.stdout;\ py_compile.compile(r'%')\"
  autocmd FileType python set efm=%C\ %.%#,%A\ \ File\ \"%f\"\\,\ line\ %l%.%#,%Z%[%^\ ]%\\@=%m
  
  " Change indent widths for old-style filetypes
  autocmd FileType java,c,cpp setlocal shiftwidth=4 softtabstop=4 

  "JAVA ANT
  " ant make for java
  autocmd FileType java setlocal makeprg=cd\ $projectHome&&ant
  " java errorformat for ant
  autocmd FileType java setlocal errorformat=\ %#[%.%#]\ %#%f:%l:%v:%*\\d:%*\\d:\ %t%[%^:]%#:%m,
    \%A\ %#[%.%#]\ %f:%l:\ %m,%-Z\ %#[%.%#]\ %p^,%C\ %#[%.%#]\ %#%m
  " java errorformat for make
"  autocmd FileType java setlocal errorformat=%A%f:%l:\ %m,%-Z%p^,%Csymbol\ \ :\ %m,%-C%.%#
  " Set up quickFix
  autocmd BufRead *.java set efm=%A\ %#[javac]\ %f:%l:\ %m,%-Z\ %#[javac]\ %p^,%-C%.%#

  " RUBY
  autocmd FileType ruby setlocal makeprg=ruby

  " COFFEE
  autocmd FileType coffee setlocal makeprg=coffee\ --output\ \/tmp

  " XCODE make file 
  "autocmd FileType c setlocal makeprg=cd\ $projectHome&&xcodebuild


  autocmd QuickFixCmdPre make wall!  "save all before make
  "autocmd QuickFixCmdPost make copen 5  " try to fix up windows after make
  "autocmd QuickFixCmdPost make wincmd w " try to fix up windows after make

  " When editing a file, always jump to the last known cursor position.
  " Don't do it when the position is invalid or when inside an event handler
  " (happens when dropping a file on gvim).
  autocmd BufReadPost *
    \ if line("'\"") > 0 && line("'\"") <= line("$") |
    \   exe "normal! g`\"" |
    \ endif

  "Add write autocmds here (although i had trouble adding an F12)
  "autocmd BufWritePost * execute 

  augroup END 
else 
  set autoindent		" always set autoindenting on 
endif " has("autocmd")

"""""""""""""""""""""""""""""""""""""""""""""""""""
" Project mappings 
"""""""""""""""""""""""""""""""""""""""""""""""""""
" F12 regenerates ctags et al, S-F12 refreshes Eclipse projects
execute 'map <F12> <esc>:silent !'.$HOME.'/.vim/bin/refresh_tags.sh &<CR>'

map <F9> :cprev<CR>
map <F10> :cnext<CR>


""""""""""""""""""""""""""""""""""""""""""""""""""""
" Ctags support
""""""""""""""""""""""""""""""""""""""""""""""""""""

" CoffeeTags, requires coffeetags
" https://github.com/lukaszkorecki/CoffeeTags
if executable('coffeetags')
  let g:tagbar_type_coffee = {
        \ 'ctagsbin' : 'coffeetags',
        \ 'ctagsargs' : '',
        \ 'kinds' : [
        \ 'f:functions',
        \ 'o:object',
        \ ],
        \ 'sro' : ".",
        \ 'kind2scope' : {
        \ 'f' : 'object',
        \ 'o' : 'object',
        \ }
        \ }
endif
