function Link(el)
  -- Handle Obsidian wiki links [[Note Title]]
  if el.target:match('%[%[.*%]%]') then
    local link = el.target:gsub('%[%[(.-)%]%]', '%1')
    -- Extract alias if present (Note Title|Alias)
    local title, alias = link:match('^(.*)|(.*)$')
    if alias then
      el.target = title .. '.md'
      el.content = { pandoc.Str(alias) }
    else
      el.target = link .. '.md'
    end
  end
  return el
end

-- Handle Obsidian-style tags with peek.nvim styling
function Span(el)
  if el.content and #el.content == 1 and el.content[1].t == 'Str' then
    local content = el.content[1].text
    if content:match '^#[%w_-][%w%d_-]*' then -- Obsidian tag pattern
      el.attributes = el.attributes or {}
      el.attributes.class = (el.attributes.class or '') .. ' obsidian-tag peek-tag'
    end
  end
  return el
end

-- Enhance code blocks for peek.nvim styling
function CodeBlock(cb)
  cb.attributes = cb.attributes or {}
  cb.attributes.class = (cb.attributes.class or '') .. ' peek-code-block'
  return cb
end

-- Enhance headers for peek.nvim styling
function Header(h)
  h.attributes = h.attributes or {}
  h.attributes.class = (h.attributes.class or '') .. ' peek-header'
  return h
end