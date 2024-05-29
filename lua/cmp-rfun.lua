
local source = {}

source.new = function()
  local self = setmetatable({}, { __index = source })
  return self
end

function source:is_available()
  return vim.bo.filetype == 'r' or vim.bo.filetype == 'rmd'
end

function source:get_debug_name()
  return 'cmp-rfun'
end

function source:complete(params, callback)
  local bufnr = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local candidates = {}
  local seen = {}
  local gmatch = string.gmatch

  for _, line in ipairs(lines) do
    for package, func in gmatch(line, '([%w_]+)::([%w_]+)') do
      local label = package .. '::' .. func .. '()'
      if not seen[label] then
        table.insert(candidates, {
          label = label,
          kind = require('cmp.types').lsp.CompletionItemKind.Function,
          insertText = package .. '::' .. func .. '($1)',
          insertTextFormat = require('cmp.types').lsp.InsertTextFormat.Snippet,
        })
        seen[label] = true
      end
    end
  end

  callback({ items = candidates, isIncomplete = false })
end

return source
