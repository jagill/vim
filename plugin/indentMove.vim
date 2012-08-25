" This is my version of http://vim.wikia.com/wiki/Move_to_next/previous_line_with_same_indentation
" I needed the option to move to a line with a different level of indentation,
" instead of just a lower level.
"
" Jump to the next or previous line that has the same level (or different
" level) of indentation than the current line.
"
" exclusive (bool): true: Motion is exclusive
"   false: Motion is inclusive
" fwd (bool): true: Go to next line
"   false: Go to previous line
" different (bool): true: Go to line with different indentation level
"   false: Go to line with the same indentation level
" skipblanks (bool): true: Skip blank lines
"   false: Don't skip blank lines
"
"
function! NextIndent(exclusive, fwd, different, skipblanks)
  let line = line('.')
  let column = col('.')
  let lastline = line('$')
  let indent = indent(line)
  let stepvalue = a:fwd ? 1 : -1
  while (line > 0 && line <= lastline)
    let line = line + stepvalue
    if (! a:skipblanks || strlen(getline(line)) > 0)
      if ( ! a:different && indent(line) == indent ||
          \ a:different && indent(line) != indent)
        if (a:exclusive)
          let line = line - stepvalue
        endif
        exe line
        exe "normal " column . "|"
        return
      endif
    endif
  endwhile
endfunction

