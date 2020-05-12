let b:prettier_ft_default_args = {
  \ 'parser': 'css',
  \ }

augroup Prettier
  autocmd!
  if get(g:, 'prettier#autoformat')
    autocmd BufWritePre *.css call prettier#Autoformat()
  endif
augroup end
