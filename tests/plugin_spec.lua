local function load_with(parsers)
  package.loaded["nvim-treesitter.parsers"] = parsers
  package.preload["nvim-treesitter.parsers"] = function()
    return parsers
  end
  dofile("plugin/sema.lua")
end

local modern = {}
load_with(modern)
assert(modern.sema, "current nvim-treesitter parser registration is missing")
assert(modern.sema.install_info.url:match("tree%-sitter%-sema$"))

local legacy_configs = {}
load_with({
  get_parser_configs = function()
    return legacy_configs
  end,
})
assert(legacy_configs.sema, "legacy nvim-treesitter parser registration is missing")

local autocmds = vim.api.nvim_get_autocmds({ group = "sema_treesitter" })
local events = {}
for _, autocmd in ipairs(autocmds) do
  events[autocmd.event] = true
end
assert(events.FileType, "Sema highlighting is not started on FileType")
assert(events.User, "parser registration is not refreshed on TSUpdate")

local query_file = assert(io.open("queries/sema/highlights.scm", "r"))
local query = query_file:read("*a")
query_file:close()
for _, name in ipairs({
  "bytes/length",
  "async/with-timeout",
  "path/canonicalize",
  "db/open",
  "workflow/mcp-handle",
}) do
  assert(
    query:find('"' .. name .. '"', 1, true),
    "documented symbol missing from highlights: " .. name
  )
end
assert(not query:find('"with-budget"', 1, true), "obsolete with-budget form is still highlighted")
assert(query:find('"llm/with-budget"', 1, true), "llm/with-budget is missing")
