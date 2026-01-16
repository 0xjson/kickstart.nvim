return {
  {
    'saghen/blink.nvim',
    dependencies = {
      'saghen/blink.cmp',
    },
    opts = {
      kepmap = {
        preset = 'default',

        ['<CR>'] = { 'accept', 'fallback' },
      },
    },
  },
}
