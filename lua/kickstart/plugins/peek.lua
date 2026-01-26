return {
  {
    'toppair/peek.nvim',
    event = { 'VeryLazy' },
    build = 'deno task --quiet build:fast',
    config = function()
      require('peek').setup {
        auto_load = true,
        close_on_bdelete = true,
        syntax = true,
        theme = 'dark',
        update_on_change = true,
        app = 'browser', -- 'webview', 'browser', string or a table of strings
        filetype = { 'markdown', 'markdown.obsidian' },
        throttle_at = 200000, -- file size, change it to 0 to disable throttling
        throttle_time = 'auto',
      }
      -- Preprocess markdown to handle Obsidian syntax
      local function preprocess_obsidian_markdown()
        local buf = vim.api.nvim_get_current_buf()
        local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
        local processed = {}
        local in_frontmatter = false
        local frontmatter_lines = {}

        for i, line in ipairs(lines) do
          -- Handle YAML frontmatter
          if i == 1 and line == '---' then
            in_frontmatter = true
            table.insert(frontmatter_lines, line)
          elseif in_frontmatter and line == '---' then
            in_frontmatter = false
            -- Convert frontmatter to HTML
            table.insert(processed, '<div class="frontmatter">')
            for _, fm_line in ipairs(frontmatter_lines) do
              if fm_line ~= '---' and fm_line:match ':' then
                local key, value = fm_line:match '^([^:]+):%s*(.+)$'
                if key and value then
                  table.insert(
                    processed,
                    string.format('<div><span class="frontmatter-key">%s:</span> <span class="frontmatter-value">%s</span></div>', key, value)
                  )
                end
              end
            end
            table.insert(processed, '</div>')
            table.insert(processed, '')
            frontmatter_lines = {}
          elseif in_frontmatter then
            table.insert(frontmatter_lines, line)
          else
            -- Handle custom checkboxes
            local checkbox_line = line
            checkbox_line = checkbox_line:gsub('^%s*%- %[>%]', '<li data-task=">">') -- blocked
            checkbox_line = checkbox_line:gsub('^%s*%- %[<%]', '<li data-task="<">') -- in-progress
            checkbox_line = checkbox_line:gsub('^%s*%- %[~%]', '<li data-task="~">') -- deferred
            checkbox_line = checkbox_line:gsub('^%s*%- %[%-]', '<li data-task="-">') -- cancelled

            -- Handle wiki links [[link]]
            checkbox_line = checkbox_line:gsub('%[%[([^%]]+)%]%]', function(link)
              local text, alias = link:match '([^|]+)|(.+)'
              if alias then
                return string.format('[%s](%s.md)', alias, text)
              else
                return string.format('[%s](%s.md)', link, link)
              end
            end)

            table.insert(processed, checkbox_line)
          end
        end

        return processed
      end

      -- Create a preprocessed temp file for peek
      local temp_file = nil
      local function update_preview()
        if not peek.is_open() then
          return
        end

        local processed = preprocess_obsidian_markdown()
        temp_file = temp_file or vim.fn.tempname() .. '.md'

        vim.fn.writefile(processed, temp_file)

        -- Trigger peek update
        vim.cmd('edit ' .. temp_file)
        vim.cmd 'buffer #'
      end

      -- Auto-update on buffer write
      vim.api.nvim_create_autocmd('BufWritePost', {
        pattern = '*.md',
        callback = function()
          if peek.is_open() then
            vim.defer_fn(update_preview, 100)
          end
        end,
      })

      vim.api.nvim_create_user_command('PeekOpen', require('peek').open, {})
      vim.api.nvim_create_user_command('PeekClose', require('peek').close, {})
    end,
  },
}
