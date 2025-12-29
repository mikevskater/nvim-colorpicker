" ============================================================================
" Vim Highlights Test File - nvim-colorpicker
" ============================================================================
"
" TEST INSTRUCTIONS:
" 1. Run :ColorHighlight to see inline color previews
" 2. Position cursor on guifg=#XXXXXX or guibg=#XXXXXX
" 3. Run :ColorPickerAtCursor to open picker and replace
" 4. The guifg/guibg prefix should be preserved
"
" ============================================================================

" ----------------------------------------------------------------------------
" Section 1: Basic Highlight Commands
" Test: guifg and guibg detection
" ----------------------------------------------------------------------------

highlight Normal guifg=#D4D4D4 guibg=#1E1E1E
highlight Comment guifg=#6A9955 gui=italic
highlight String guifg=#CE9178
highlight Number guifg=#B5CEA8
highlight Keyword guifg=#569CD6 gui=bold
highlight Function guifg=#DCDCAA
highlight Type guifg=#4EC9B0

" Short form
hi Identifier guifg=#9CDCFE
hi Constant guifg=#4FC1FF
hi Statement guifg=#C586C0

" With gui attributes
hi Todo guifg=#1E1E1E guibg=#FFCC00 gui=bold
hi Error guifg=#FFFFFF guibg=#F44747 gui=bold
hi Warning guifg=#1E1E1E guibg=#CCA700

" ----------------------------------------------------------------------------
" Section 2: Multiple Colors on Same Line
" Test: Multiple guifg/guibg on one line
" ----------------------------------------------------------------------------

highlight StatusLine guifg=#FFFFFF guibg=#007ACC gui=bold
highlight StatusLineNC guifg=#808080 guibg=#3C3C3C
highlight VertSplit guifg=#3C3C3C guibg=#1E1E1E

" TabLine variants
hi TabLine guifg=#808080 guibg=#2D2D2D
hi TabLineFill guifg=#808080 guibg=#252526
hi TabLineSel guifg=#FFFFFF guibg=#1E1E1E gui=bold

" ----------------------------------------------------------------------------
" Section 3: Force Highlight (hi!)
" Test: hi! command detection
" ----------------------------------------------------------------------------

hi! link MyCustomGroup Normal
hi! clear MyGroup
hi! MyForced guifg=#FF5500 guibg=#1A1A1A gui=underline

" ----------------------------------------------------------------------------
" Section 4: Cursor and Selection
" Test: Cursor-related highlights
" ----------------------------------------------------------------------------

highlight Cursor guifg=#1E1E1E guibg=#AEAFAD
highlight CursorLine guibg=#2A2D2E
highlight CursorColumn guibg=#2A2D2E
highlight CursorLineNr guifg=#C6C6C6 guibg=#1E1E1E gui=bold
highlight LineNr guifg=#858585

" Visual selection
highlight Visual guibg=#264F78
highlight VisualNOS guibg=#264F78

" ----------------------------------------------------------------------------
" Section 5: Search Highlights
" Test: Search-related colors
" ----------------------------------------------------------------------------

highlight Search guifg=#1E1E1E guibg=#F8DC3D
highlight IncSearch guifg=#1E1E1E guibg=#FF9632
highlight Substitute guifg=#1E1E1E guibg=#FF5500

" Match highlighting
highlight MatchParen guifg=#FFFFFF guibg=#0D7377 gui=bold
highlight CurSearch guifg=#1E1E1E guibg=#E2C08D gui=bold

" ----------------------------------------------------------------------------
" Section 6: Popup Menu (Completion)
" Test: Pmenu colors
" ----------------------------------------------------------------------------

highlight Pmenu guifg=#D4D4D4 guibg=#252526
highlight PmenuSel guifg=#FFFFFF guibg=#0A7ACA
highlight PmenuSbar guibg=#3C3C3C
highlight PmenuThumb guibg=#808080

" Float windows
highlight NormalFloat guifg=#D4D4D4 guibg=#252526
highlight FloatBorder guifg=#3C3C3C guibg=#252526
highlight FloatTitle guifg=#569CD6 guibg=#252526 gui=bold

" ----------------------------------------------------------------------------
" Section 7: Diff Colors
" Test: Diff highlighting
" ----------------------------------------------------------------------------

highlight DiffAdd guifg=#FFFFFF guibg=#587C0C
highlight DiffChange guifg=#FFFFFF guibg=#0C7D9D
highlight DiffDelete guifg=#FFFFFF guibg=#94151B
highlight DiffText guifg=#FFFFFF guibg=#007ACC gui=bold

" Git signs style
hi GitSignsAdd guifg=#587C0C
hi GitSignsChange guifg=#0C7D9D
hi GitSignsDelete guifg=#94151B

" ----------------------------------------------------------------------------
" Section 8: Diagnostic Colors
" Test: LSP/diagnostic highlights
" ----------------------------------------------------------------------------

highlight DiagnosticError guifg=#F44747
highlight DiagnosticWarn guifg=#CCA700
highlight DiagnosticInfo guifg=#3794FF
highlight DiagnosticHint guifg=#B0B0B0

" Underline variants
hi DiagnosticUnderlineError gui=underline guisp=#F44747
hi DiagnosticUnderlineWarn gui=underline guisp=#CCA700
hi DiagnosticUnderlineInfo gui=underline guisp=#3794FF
hi DiagnosticUnderlineHint gui=underline guisp=#B0B0B0

" Virtual text
hi DiagnosticVirtualTextError guifg=#F44747 guibg=#3A1D1D
hi DiagnosticVirtualTextWarn guifg=#CCA700 guibg=#3A3A1D
hi DiagnosticVirtualTextInfo guifg=#3794FF guibg=#1D2A3A
hi DiagnosticVirtualTextHint guifg=#B0B0B0 guibg=#2D2D2D

" ----------------------------------------------------------------------------
" Section 9: Treesitter Highlights
" Test: @-prefixed groups (may need special handling)
" ----------------------------------------------------------------------------

" These are typically set via nvim_set_hl in Lua, but show vim syntax
highlight @comment guifg=#6A9955 gui=italic
highlight @string guifg=#CE9178
highlight @number guifg=#B5CEA8
highlight @keyword guifg=#569CD6 gui=bold
highlight @function guifg=#DCDCAA
highlight @variable guifg=#9CDCFE
highlight @type guifg=#4EC9B0
highlight @constant guifg=#4FC1FF
highlight @parameter guifg=#9CDCFE gui=italic
highlight @property guifg=#9CDCFE

" Treesitter semantic tokens
hi @lsp.type.class guifg=#4EC9B0
hi @lsp.type.function guifg=#DCDCAA
hi @lsp.type.method guifg=#DCDCAA
hi @lsp.type.property guifg=#9CDCFE
hi @lsp.type.variable guifg=#9CDCFE

" ----------------------------------------------------------------------------
" Section 10: Plugin-Specific Highlights
" Test: Common plugin highlight patterns
" ----------------------------------------------------------------------------

" NvimTree
highlight NvimTreeNormal guifg=#D4D4D4 guibg=#1E1E1E
highlight NvimTreeFolderIcon guifg=#E8AB53
highlight NvimTreeFolderName guifg=#D4D4D4
highlight NvimTreeOpenedFolderName guifg=#D4D4D4 gui=bold
highlight NvimTreeGitDirty guifg=#E8AB53
highlight NvimTreeGitNew guifg=#587C0C

" Telescope
highlight TelescopeNormal guibg=#1E1E1E
highlight TelescopeBorder guifg=#3C3C3C guibg=#1E1E1E
highlight TelescopePromptBorder guifg=#569CD6 guibg=#252526
highlight TelescopePromptNormal guibg=#252526
highlight TelescopePromptTitle guifg=#1E1E1E guibg=#569CD6 gui=bold
highlight TelescopeSelection guibg=#264F78
highlight TelescopeMatching guifg=#CE9178 gui=bold

" Indent guides
highlight IndentBlanklineChar guifg=#3C3C3C
highlight IndentBlanklineContextChar guifg=#569CD6
highlight IndentBlanklineSpaceChar guifg=#3C3C3C

" Which-key
highlight WhichKey guifg=#569CD6
highlight WhichKeyGroup guifg=#C586C0
highlight WhichKeyDesc guifg=#D4D4D4
highlight WhichKeySeparator guifg=#6A9955
highlight WhichKeyFloat guibg=#1E1E1E

" ----------------------------------------------------------------------------
" Section 11: Terminal Colors
" Test: Terminal ANSI color definitions
" ----------------------------------------------------------------------------

let g:terminal_color_0 = '#1E1E1E'
let g:terminal_color_1 = '#F44747'
let g:terminal_color_2 = '#587C0C'
let g:terminal_color_3 = '#CCA700'
let g:terminal_color_4 = '#569CD6'
let g:terminal_color_5 = '#C586C0'
let g:terminal_color_6 = '#4EC9B0'
let g:terminal_color_7 = '#D4D4D4'
let g:terminal_color_8 = '#808080'
let g:terminal_color_9 = '#F44747'
let g:terminal_color_10 = '#587C0C'
let g:terminal_color_11 = '#CCA700'
let g:terminal_color_12 = '#569CD6'
let g:terminal_color_13 = '#C586C0'
let g:terminal_color_14 = '#4EC9B0'
let g:terminal_color_15 = '#FFFFFF'

" ----------------------------------------------------------------------------
" Section 12: Colorscheme Function Example
" Test: Colors in function context
" ----------------------------------------------------------------------------

function! s:ApplyHighlights()
  highlight Normal guifg=#E0E0E0 guibg=#121212
  highlight NonText guifg=#404040
  highlight SpecialKey guifg=#404040
  highlight EndOfBuffer guifg=#121212

  " Syntax groups
  hi Statement guifg=#C586C0 gui=NONE
  hi Conditional guifg=#C586C0
  hi Repeat guifg=#C586C0
  hi Label guifg=#C586C0
  hi Exception guifg=#C586C0

  " Special
  hi Special guifg=#D7BA7D
  hi SpecialChar guifg=#D7BA7D
  hi Tag guifg=#569CD6
  hi Delimiter guifg=#D4D4D4
endfunction
