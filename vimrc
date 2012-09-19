set nocompatible	" don't try to be vi (This must be first)

" Pathogen config. This allows us a vim 'package maintainer'
" If this is not running, you need to run 
" $HOME/.vim/bin/update_plugins.py --help
" to see how to install pathogen and other plugins.
filetype off 
call pathogen#runtime_append_all_bundles()
call pathogen#helptags()
filetype plugin indent on

"""""""""""""""""""""""""""""""""""""""""""""""""""
" Problems to overcome:
" 1. Cut/paste working smoothly -- Done?
" 2. Set up Cscope in a helpful way
" 3. Fix neocomplcache issues
" 4. Make "ge" equiv in camelcasemotion
" 5. Fix fn-Opt-Delete
"""""""""""""""""""""""""""""""""""""""""""""""""""
" settings
"""""""""""""""""""""""""""""""""""""""""""""""""""


set hidden          " Allow buffers to be hidden without writing, and remember their marks.
set autowrite       " Autosave when I use tags, switch buffers, etc
set ruler		    " Show the cursor position all the time
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
set tabstop=4	    " tabs show as 4 spaces 
set title           " Show title of file in terminal mode
set shortmess=I     " Suppress many of the "Press RETURN to continue"
set visualbell      " Don't audibly beep
set wildmenu        " Show all possible word completions
" set wildmode=list:longest     " Only complete up to points of ambiguity
set wildmode=list:longest,full  " You can also toggle through the matches by tab
"Ignore these files when completing names and in Explorer
set wildignore=.svn,CVS,.git,*.o,*.a,*.class,*.mo,*.la,*.so,*.obj,*.swp,*.jpg,*.png,*.xpm,*.gif,*~,*.pyc,*.pyo
let &tags=$projectHome . '/.tags'  " ctags file location
set path=$projectHome/**  " set the project root as the base directory for find command
set grepprg=ack\ --type-add\ jsp=.vm\ --ignore-dir=bin\ --ignore-dir=build " use ack not grep for searching

set mouse=a 		" this enables vim mouse handling, and mucks up cut-paste from putty
set mouseshape=i:beam

set clipboard=unnamed   " Default for all unnamed yank/etc operations to store in system clipboard

"set diffopt+=iwhite    "Ignore whitespace when diffing

"Placing the line set complete=.,w,b,u,t,i in your ~/.vimrc file allows you to automatically complete any class, method, or field name by pressing [Ctrl]N while in insert mode. Successive presses of [Ctrl]N bring up the next matches. When you see the tag you want, just continue typing the rest of your source code. 
set complete=.,w,b,u,t,i

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

"Make Y work consistently with C and D
noremap Y y$

" Abbreviations
" Alias %% to the directory of the current file.
cabbr <expr> %% expand('%:p:h') 

" make ZZ work how I expect with multiple buffers
noremap  ZZ :wqa<CR>

" Edit the .vimrc file
map <Leader>v :sp $HOME/.vimrc<CR>
" Reload .vimrc
map <silent> <Leader>V :source $HOME/.vimrc<CR>:filetype detect<CR>:exe ":echo 'vimrc reloaded'"<CR>
map <F1> :grep <cword><CR>

" Copy current register into clipboard in mac
if has("macunix")
  nmap <silent> <Leader>p :call system('echo ' . shellescape(getreg()) . ' \| pbcopy')<CR> 
endif

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
  map  <C-BS>         d<C-Left>
  map! <C-BS>         <C-o>d<C-Left>
  map  <C-Del>        d<C-Right>
  map! <C-Del>        <C-o>d<C-Right>
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
let g:miniBufExplMapCTabSwitchBufs = 1 " control-tab and control-shift-tab to switch buffers 
"let g:miniBufExplMapWindowNavVim = 1   " control-[hjkl] to move among windows 
"let g:miniBufExplMapWindowNavArrows = 1   " control-<arrows> to move among windows 
map <Leader>bb :MiniBufExplorer<cr>  " Open and/or goto Explorer
map <Leader>bc :CMiniBufExplorer<cr> " Close the Explorer if it's open
map <Leader>bu :UMiniBufExplorer<cr> " Update Explorer without navigating
map <Leader>bt :TMiniBufExplorer<cr> " Toggle the Explorer window open and closed.

"Map NERDTree commands
noremap <silent> <Leader>nt :NERDTreeToggle<CR>
noremap <silent> <Leader>ntf :NERDTreeFind<CR>

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

" CheckSyntax
" F5 mapping conflicts with ours, remap it
noremap <Leader>S :CheckSyntax<CR>

"YankRing
"Make the history file unobtrusive
let g:yankring_history_file = '.yankring_history'
"Don't put a single char in the registers
let g:yankring_min_element_length=2
" YankRing keeps the last nine yanks/etc, not just the standard last 9 deletes.
" This is currently bugged -- mailed author, who will fix it someday.
let g:yankring_manage_numbered_reg = 1
" Map Y to be consistent with C and D.  YankRing requires this to a be a
" little more complicated.
function! YRRunAfterMaps()
    nnoremap Y   :<C-U>YRYankCount 'y$'<CR>
endfunction
" Show the ring with \y (for yank)
nmap <silent> <Leader>y :YRShow<CR>

" NERDCommenter
:map <silent> <Leader>ct :call NERDComment(1, 'toggle')<CR>

" neocomplcache
"" Use neocomplcache.
let g:neocomplcache_enable_at_startup = 1
"" Use smartcase.
let g:neocomplcache_enable_smart_case = 1
"" Use camel case completion.
let g:neocomplcache_enable_camel_case_completion = 1
"" Use underbar completion.
let g:neocomplcache_enable_underbar_completion = 1
"" Set minimum syntax keyword length.
let g:neocomplcache_auto_completion_start_length = 3
let g:neocomplcache_manual_completion_start_length = 3
"let g:neocomplcache_lock_buffer_name_pattern = '\*ku\*'
let g:neocomplcache_snippets_dir = $VIMDIR . './snippets'

"" Define dictionary.
"let g:neocomplcache_dictionary_filetype_lists = {
"    \ 'default' : '',
"    \ 'vimshell' : $HOME.'/.vimshell_hist',
"   \ 'scheme' : $HOME.'/.gosh_completions'
"    \ }

" Define keyword.
if !exists('g:neocomplcache_keyword_patterns')
    let g:neocomplcache_keyword_patterns = {}
endif
let g:neocomplcache_keyword_patterns['default'] = '\h\w*'

"Have neocomplcache complete on tab. Seems to be old; disabled for now.
"smap  <TAB>  <RIGHT><Plug>(neocomplcache_snippets_jump)
"inoremap <expr><C-e>     neocomplcache#complete_common_string() 
"
"" SuperTab like snippets behavior.
imap <expr><TAB> neocomplcache#sources#snippets_complete#expandable() ? "\<Plug>(neocomplcache_snippets_expand)" : pumvisible() ? "\<C-n>" : "\<TAB>"


"" Plugin key-mappings.
imap <C-k>     <Plug>(neocomplcache_snippets_expand)
smap <C-k>     <Plug>(neocomplcache_snippets_expand)
"inoremap <expr><C-g>     neocomplcache#undo_completion()
"inoremap <expr><C-l>     neocomplcache#complete_common_string()


" Recommended key-mappings.
" <CR>: close popup and save indent.
"inoremap <expr><CR>  neocomplcache#smart_close_popup() . (&indentexpr != '' ? "\<C-f>\<CR>X\<BS>":"\<CR>")
" <TAB>: completion.
inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"
" <C-h>, <BS>: close popup and delete backword char.
inoremap <expr><C-h> neocomplcache#smart_close_popup()."\<C-h>"
inoremap <expr><BS> neocomplcache#smart_close_popup()."\<C-h>"
"inoremap <expr><C-y>  neocomplcache#close_popup()
"inoremap <expr><C-e>  neocomplcache#cancel_popup()


"" Enable omni completion.
autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags 

"alternate.txt
"Set up alternates that handle objc/objcpp
let g:alternateExtensions_h = "c,cpp,cxx,cc,m,mm"
let g:alternateExtensions_m = "h"
let g:alternateExtensions_mm = "h"

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
  " use filetype=htmldjango on .html files 
  autocmd BufRead,BufNewFile *.html set filetype=htmldjango
  " use filetype=python on .psp files 
  autocmd BufRead,BufNewFile *.psp set filetype=python
  " use filetype=objcpp on .mm files 
  autocmd BufRead,BufNewFile *.mm set filetype=objcpp
  " use correct filetypes for ActionScript/flex
  autocmd BufNewFile,BufRead *.mxml set filetype=mxml
  autocmd BufNewFile,BufRead *.as set filetype=actionscript

  "PYTHON
  " Check syntax and run python script.
  autocmd FileType python set makeprg=python\ -c\ \"import\ py_compile,sys;\ sys.stderr=sys.stdout;\ py_compile.compile(r'%')\"
  autocmd FileType python set efm=%C\ %.%#,%A\ \ File\ \"%f\"\\,\ line\ %l%.%#,%Z%[%^\ ]%\\@=%m
  
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


  augroup END 
else 
  set autoindent		" always set autoindenting on 
endif " has("autocmd")

"""""""""""""""""""""""""""""""""""""""""""""""""""
" Project mappings 
"""""""""""""""""""""""""""""""""""""""""""""""""""
" F12 regenerates ctags et al, S-F12 refreshes Eclipse projects
execute 'map <F12> <esc>:!'.$HOME.'/.vim/bin/refresh_tags.sh &<CR>'
execute 'map <S-F12> <esc>:ProjectRefresh<CR>'

map <F9> :cprev<CR>
map <F10> :cnext<CR>

"F6 uses Eclim's JavaCorrect.  F7 (+S) adds an
" import or adds all imports and cleans.
"execute 'map <F6> <esc>:JavaCorrect<CR>'
"execute 'map <F7> <esc>:JavaImport<CR>'
"execute 'map <S-F7> <esc>:JavaImportMissing<CR>:JavaImportClean<CR>:JavaImportSort<CR>'
"execute 'map <F11> <esc>:wall!<CR>:!cleansource<CR>'


