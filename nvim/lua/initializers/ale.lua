vim.cmd('highlight clear SpellBad')
vim.cmd('highlight SpellBad cterm=underline')
vim.cmd('highlight clear ALEError')
vim.cmd('highlight ALEError cterm=underline')
vim.cmd('highlight clear ALEWarning')
vim.cmd('highlight ALEWarning cterm=underline')

vim.g.ale_fixers = {
  javascript = {'prettier'},
  ['*'] = {'remove_trailing_lines', 'trim_whitespace'},
}

vim.g.ale_linters = {
  javascript = {'eslint'},
  jsx = {'eslint'},
}
