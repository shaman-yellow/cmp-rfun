
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

local function get_script_dir()
  local info = debug.getinfo(1, 'S')
  local script_path = info.source:sub(2)
  return script_path:match("(.*[/\\])")
end

function source:complete(params, callback)
  local candidates = {}
  local seen = {}
  local function add_candidate(label)
    if not seen[label] then
      table.insert(candidates, {
        label = label,
        kind = require('cmp.types').lsp.CompletionItemKind.Function,
        insertText = string.format("%s($1)", label),
        insertTextFormat = require('cmp.types').lsp.InsertTextFormat.Snippet,
      })
      seen[label] = true
    end
  end

  local filename
  if vim.g.cmp_rfun_file then
    filename = vim.g.cmp_rfun_file
  else
    -- Get the directory of the current script and build the relative path
    local script_dir = get_script_dir()
    filename = script_dir .. 'functions.txt'
  end

  -- Load external text
  for line in io.lines(filename) do
    add_candidate(line)
  end

  -- Load candidates from the current buffer
  local bufnr = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local gmatch = string.gmatch

  for _, line in ipairs(lines) do
    for package, func in gmatch(line, '([%w_]+)::([%w_]+)') do
      local label = package .. '::' .. func .. '()'
      add_candidate(label)
    end
  end

  callback({ items = candidates, isIncomplete = false })
end

return source
