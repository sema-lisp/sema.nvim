-- Neovim integration for the Sema language: tree-sitter parser, language
-- server (`sema lsp`), and debug adapter (`sema dap`). Everything here is
-- guarded so missing optional dependencies (nvim-treesitter, nvim-dap) are a
-- no-op — the plugin never errors on load.

-- ── Tree-sitter ─────────────────────────────────────────────────────────
-- Register the tree-sitter-sema parser so `:TSInstall sema` fetches and
-- compiles it. Highlight queries ship under queries/sema/ on the runtimepath.
-- nvim-treesitter's current main branch exposes its parser table directly;
-- the compatibility `master` branch still uses `get_parser_configs()`.
local sema_parser = {
  install_info = {
    url = "https://github.com/sema-lisp/tree-sitter-sema",
    files = { "src/parser.c", "src/scanner.c" },
    branch = "main",
  },
  filetype = "sema",
}

local function register_parser()
  local ok_ts, parsers = pcall(require, "nvim-treesitter.parsers")
  if not ok_ts then
    return
  end

  if type(parsers.get_parser_configs) == "function" then
    parsers.get_parser_configs().sema = sema_parser
  else
    parsers.sema = sema_parser
  end
end

register_parser()

local treesitter_group = vim.api.nvim_create_augroup("sema_treesitter", { clear = true })
vim.api.nvim_create_autocmd("User", {
  group = treesitter_group,
  pattern = "TSUpdate",
  callback = register_parser,
})

local function start_highlighting(args)
  if vim.treesitter and vim.treesitter.start then
    pcall(vim.treesitter.start, args.buf, "sema")
  end
end

vim.api.nvim_create_autocmd("FileType", {
  group = treesitter_group,
  pattern = "sema",
  callback = start_highlighting,
})

-- A filetype-triggered plugin is loaded while the first FileType event is
-- already being handled, so start that buffer explicitly as well.
if vim.bo.filetype == "sema" then
  local initial_buf = vim.api.nvim_get_current_buf()
  vim.schedule(function()
    if vim.api.nvim_buf_is_valid(initial_buf) then
      start_highlighting({ buf = initial_buf })
    end
  end)
end

-- ── Language server (`sema lsp`) ────────────────────────────────────────
-- Uses the native vim.lsp API (Neovim 0.11+); falls back to a FileType
-- autocmd on older versions. No nvim-lspconfig dependency.
if vim.lsp and vim.lsp.config and vim.lsp.enable then
  vim.lsp.config("sema", {
    cmd = { "sema", "lsp" },
    filetypes = { "sema" },
    root_markers = { "sema.toml", ".git" },
  })
  vim.lsp.enable("sema")
elseif vim.lsp and vim.lsp.start then
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "sema",
    callback = function(args)
      local fname = vim.api.nvim_buf_get_name(args.buf)
      local found = vim.fs.find({ "sema.toml", ".git" }, { upward = true, path = fname })[1]
      vim.lsp.start({
        name = "sema",
        cmd = { "sema", "lsp" },
        root_dir = found and vim.fs.dirname(found) or vim.fs.dirname(fname),
      })
    end,
  })
end

-- ── Debug adapter (`sema dap`) ──────────────────────────────────────────
-- Registered only when nvim-dap is present. Start a session with
-- `:lua require('dap').continue()` and pick "Launch Sema file".
local ok_dap, dap = pcall(require, "dap")
if ok_dap then
  dap.adapters.sema = {
    type = "executable",
    command = "sema",
    args = { "dap" },
  }
  dap.configurations.sema = {
    {
      type = "sema",
      request = "launch",
      name = "Launch Sema file",
      program = "${file}",
      stopOnEntry = false,
    },
  }
end
