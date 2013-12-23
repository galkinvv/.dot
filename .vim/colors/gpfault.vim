" Vim color file


set background=dark
hi clear
let colors_name = "gpfault"

" Normal should come first
hi Normal     ctermbg=black ctermfg=grey guifg=grey80 guibg=grey20
hi Cursor     guibg=#90F0E0  guifg=NONE
"hi lCursor    guifg=NONE   guibg=Cyan

hi DiffAdd    ctermbg=Green        guibg=#204020
hi DiffChange ctermbg=Blue     	   guibg=#202040
hi DiffText   ctermbg=Brown	   guibg=#303060
"hi DiffDelete ctermbg=Red	   guibg=#402020
"make this invisible
hi DiffDelete ctermbg=bg ctermfg=bg  guibg=bg guifg=bg
"hi Directory
hi ErrorMsg   ctermfg=White 	   ctermbg=DarkRed  guibg=DarkRed	    guifg=White
"hi FoldColumn ctermfg=DarkBlue	   ctermbg=Grey     guibg=Grey	    guifg=DarkBlue
"hi Folded     ctermbg=Grey	   ctermfg=DarkBlue guibg=LightGrey guifg=DarkBlue
hi IncSearch  ctermfg=NONE ctermbg=green  cterm=none     guifg=NONE guibg=#30b030 gui=none
"hi LineNr     ctermfg=Brown	   guifg=Brown
hi ModeMsg    ctermfg=Yellow cterm=none      guifg=Yellow  gui=none
hi MoreMsg    ctermfg=DarkGreen cterm=none   guifg=SeaGreen gui=none
hi NonText    ctermbg=grey cterm=bold     gui=bold guibg=grey50
hi Pmenu      ctermbg=grey ctermfg=black guibg=grey guifg=black
hi PmenuSel   ctermbg=green ctermfg=black guibg=lightgreen guifg=black
"hi PmenuSbar
"hi PmenuThumb
hi Question   ctermbg=grey ctermfg=DarkGreen guifg=SeaGreen
hi Search     ctermfg=NONE ctermbg=Cyan          guibg=#006060 guifg=NONE
"hi SpecialKey ctermfg=DarkBlue	   guifg=Blue
hi StatusLine ctermbg=grey ctermfg=black guibg=grey guifg=black cterm=none gui=none
"hi StatusLineNC
"hi Title      ctermfg=DarkMagenta  gui=bold guifg=Magenta"
"hi VertSplit  cterm=reverse	   gui=reverse
"for 16-color term need bg2
if &t_Co<16
	hi Visual ctermfg=NONE ctermbg=blue cterm=none  gui=none guifg=NONE guibg=grey40
else
	hi Visual ctermfg=NONE ctermbg=darkgray cterm=none  gui=none guifg=NONE guibg=grey40
endif
hi VisualNOS  cterm=underline,bold gui=underline,bold
hi WarningMsg ctermfg=Red	   guifg=Red
hi WildMenu   ctermbg=green ctermfg=black guibg=lightgreen guifg=black cterm=none gui=none

" syntax highlighting
hi Comment    ctermfg=lightRed     guifg=#ff8080 cterm=none  gui=none
hi Constant   ctermfg=Green   guifg=#90c000 cterm=none  gui=none
hi String     ctermfg=brown  guifg=#b0b000 cterm=none  gui=none
hi link Character  Special
hi link Identifier normal
hi link float number
hi link boolean number
hi number     ctermfg=lightmagenta guifg=#e070e0 cterm=none  gui=none
hi PreProc    ctermfg=lightcyan guifg=#7070f0 cterm=none  gui=none
hi Special    ctermfg=yellow  guifg=#ffff20 cterm=none  gui=none
hi Statement  ctermfg=cyan	  guifg=#50c0a0 cterm=none  gui=none
hi Type	      ctermfg=cyan	  guifg=#a0c050 cterm=none  gui=none
hi Delimiter  ctermfg=green guifg=green cterm=none  gui=none
hi MatchParen ctermbg=brown guibg=#700030
" vim: sw=2
