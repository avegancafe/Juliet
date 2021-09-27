return require('packer').startup(function()
  use {
    'glepnir/galaxyline.nvim',
    branch = 'main',
    config = function()
      require('statusline')
    end,
    requires = {'kyazdani42/nvim-web-devicons'}
  }
  use {
    'kyazdani42/nvim-tree.lua',
    requires = 'kyazdani42/nvim-web-devicons',
    config = function()
      require('nvim-tree').setup()
    end
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
    requires = { 'kyazdani42/nvim-web-devicons', 'nvim-lua/plenary.nvim' },
    config = function()
      require('telescope').setup({
        defaults = {
          path_display = { 'smart' }
        }
      })
    end
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
  use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }
  use 'mhinz/vim-startify'
  use {
    'lewis6991/gitsigns.nvim', requires = { 'nvim-lua/plenary.nvim' },
    config = function() require('gitsigns').setup() end
  }
  use 'Th3Whit3Wolf/space-nvim'
end)
