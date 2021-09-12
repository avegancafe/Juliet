return require('packer').startup(function()
  use {
    'preservim/nerdtree',
    requires = { 'kyazdani42/nvim-web-devicons' }
  }
  use {
    'autozimu/LanguageClient-neovim',
    run = 'bash install.sh',
    requires = { 'ternjs/tern_for_vim' }
  }
  use 'dense-analysis/ale'
  use 'jiangmiao/auto-pairs'
  use 'rhysd/committia.vim'
  use 'junegunn/goyo.vim'
  use 'wincent/loupe'
  use 'kaicataldo/material.vim'
  use 'kassio/neoterm'
  use {
    'nvim-telescope/telescope.nvim',
    requires = { 'kyazdani42/nvim-web-devicons', 'nvim-lua/plenary.nvim' }
  }
  use 'frazrepo/vim-rainbow'
  use 'dag/vim-fish'
  use 'heavenshell/vim-jsdoc'
  use 'MaxMEllon/vim-jsx-pretty'
  use 'groenewege/vim-less'
  use 'prettier/vim-prettier'
  use 'tomlion/vim-solidity'
  use 'tpope/vim-surround'
  use 'vim-test/vim-test'
  use 'othree/yajs.vim'
  use 'nvim-treesitter/nvim-treesitter'
  use 'mhinz/vim-startify'
  print('requiring galaxyline')
  use {
    'glepnir/galaxyline.nvim',
    branch = 'main',
    config = function() require'statusline' end,
    requires = {'kyazdani42/nvim-web-devicons'}
  }
end)
