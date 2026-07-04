-- Register the tree-sitter-sema parser with nvim-treesitter so `:TSInstall sema`
-- fetches and compiles it. Highlight queries ship alongside this plugin under
-- queries/sema/, which nvim-treesitter picks up from the runtimepath.
--
-- Guarded so this file is a no-op when nvim-treesitter isn't installed (the
-- ftplugin/LSP setup still works with plain regex or no highlighting).
local ok, parsers = pcall(require, "nvim-treesitter.parsers")
if ok and type(parsers.get_parser_configs) == "function" then
  parsers.get_parser_configs().sema = {
    install_info = {
      url = "https://github.com/HelgeSverre/tree-sitter-sema",
      files = { "src/parser.c", "src/scanner.c" },
      branch = "main",
    },
    filetype = "sema",
  }
end
