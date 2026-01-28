-- plugins/obsidian.lua
-- blink.cmp compatible configuration for Obsidian.nvim
return {
  {
    'obsidian-nvim/obsidian.nvim',
    version = '*',
    lazy = true,
    ft = 'markdown',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'saghen/blink.cmp',
    },
    opts = function()
      local obsidian_opts = {
        dir = '~/ObsidianVault',
        notes_subdir = 'notes',
        log_level = vim.log.levels.WARN,
        new_notes_location = 'current_dir',
        completion = {
          nvim_cmp = false, -- Use blink.cmp
          min_chars = 2,
        },
        frontmatter = {
          enabled = true, -- replaces disable_frontmatter
          func = function(note)
            local out = { id = note.id, aliases = note.aliases, tags = note.tags, area = '', project = '' }
            if note.metadata ~= nil and require('obsidian').util.table_length(note.metadata) > 0 then
              for k, v in pairs(note.metadata) do
                out[k] = v
              end
            end
            return out
          end,
        },
        finder = 'telescope.nvim',
        search = {
          sort_by = 'modified', -- replaces top-level sort_by
          sort_reversed = true, -- replaces top-level sort_reversed
        },
        open_notes_in = 'current',
        prepend_note_id = true,
        ui = {
          enable = true,
          update_debounce = 200,
          checkbox = {
            order = { ' ', 'x', '>', '<', '~', '-' }, -- replaces ui.checkboxes
            bullets = {
              [' '] = { char = '󰄱', hl_group = 'ObsidianTodo' }, --todo
              ['x'] = { char = '', hl_group = 'ObsidianDone' }, -- done
              ['>'] = { char = '', hl_group = 'ObsidianRightArrow' }, -- blocked
              ['<'] = { char = '', hl_group = 'ObsidianLeftArrow' }, -- in-progress
              ['~'] = { char = '󰰱', hl_group = 'ObsidianTilde' }, -- deferred
              ['-'] = { char = '󰧵', hl_group = 'ObsidianMinus' }, -- cancelled
            },
          },
          bullets = { char = '•', hl_group = 'ObsidianBullet' },
          external_link_icon = { char = '', hl_group = 'ObsidianExtLinkIcon' },
          reference_text = { hl_group = 'ObsidianRefText' },
          highlight_text = { hl_group = 'ObsidianHighlightText' },
          tags = { hl_group = 'ObsidianTag' },
          hl_groups = {
            ObsidianTodo = { bold = true, fg = '#f78c6c' },
            ObsidianDone = { bold = true, fg = '#89ddff' },
            ObsidianRightArrow = { bold = true, fg = '#f78c6c' },
            ObsidianLeftArrow = { bold = true, fg = '#f78c6c' },
            ObsidianTilde = { bold = true, fg = '#ff5370' },
            ObsidianMinus = { bold = true, fg = '#ff5370' }, -- blocked color
            ObsidianBullet = { bold = true, fg = '#89ddff' },
            ObsidianRefText = { underline = true, fg = '#c792ea' },
            ObsidianExtLinkIcon = { fg = '#c792ea' },
            ObsidianTag = { italic = true, fg = '#89ddff' },
            ObsidianHighlightText = { bg = '#75662e' },
          },
        },
        legacy_commands = false, -- Disable legacy commands
      }

      -- Add optional components if needed
      obsidian_opts.note_id_func = function(title)
        local suffix = ''
        if title ~= nil then
          suffix = title:gsub(' ', '-'):gsub('[^A-Za-z0-9-]', ''):lower()
        else
          for _ = 1, 4 do
            suffix = suffix .. string.char(math.random(65, 90))
          end
        end
        return tostring(os.time()) .. '-' .. suffix
      end

      obsidian_opts.wiki_link_func = function(opts)
        if opts.id == nil then
          return string.format('[[%s]]', opts.label)
        elseif opts.label ~= opts.id then
          return string.format('[[%s|%s]]', opts.id, opts.label)
        else
          return string.format('[[%s]]', opts.id)
        end
      end

      return obsidian_opts
    end,
    config = function(_, opts)
      require('obsidian').setup(opts)
    end,
  },
}
