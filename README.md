# sema.nvim

Neovim support for [Sema](https://sema-lang.com) (`.sema`) — a Lisp dialect with
first-class LLM primitives. Ships filetype detection, tree-sitter syntax
highlighting (via [`tree-sitter-sema`](https://github.com/sema-lisp/tree-sitter-sema)),
and opt-in wiring for the built-in `sema lsp` language server.

## Install

### lazy.nvim

```lua
{
  "sema-lisp/sema.nvim",
  ft = "sema",
  dependencies = { "nvim-treesitter/nvim-treesitter" },
}
```

### packer.nvim

```lua
use({
  "sema-lisp/sema.nvim",
  requires = { "nvim-treesitter/nvim-treesitter" },
})
```

Then run `:TSInstall sema` once to fetch and compile the grammar (it uses the
pinned [`sema-lisp/tree-sitter-sema`](https://github.com/sema-lisp/tree-sitter-sema)
url registered by this plugin). Highlighting works on the next `.sema` buffer.

## Features

- **Filetype detection** — `.sema` files are associated with the `sema`
  filetype.
- **Tree-sitter highlighting** — registers the `tree-sitter-sema` parser with
  `nvim-treesitter` so `:TSInstall sema` just works, and ships the highlight
  queries (`queries/sema/highlights.scm`) that nvim-treesitter picks up from the
  runtimepath.
- **LSP (opt-in)** — Sema ships a built-in language server (`sema lsp`):
  completions, hover, go-to-definition, references, rename, signature help,
  diagnostics, document symbols, and code lens. This plugin does **not**
  auto-start it — wire it up yourself (see below) so it stays out of your way if
  you only want highlighting.

## LSP setup

### Neovim ≥ 0.11 (native `vim.lsp`, no plugin)

```lua
vim.lsp.config.sema = {
  cmd = { "sema", "lsp" },
  filetypes = { "sema" },
  root_markers = { "sema.toml", ".git" },
}
vim.lsp.enable("sema")
```

### nvim-lspconfig

Until an upstream `sema` config ships (see [Roadmap](#roadmap)), register it
inline:

```lua
local configs = require("lspconfig.configs")
local lspconfig = require("lspconfig")

if not configs.sema then
  configs.sema = {
    default_config = {
      cmd = { "sema", "lsp" },
      filetypes = { "sema" },
      root_dir = lspconfig.util.root_pattern("sema.toml", ".git"),
      single_file_support = true,
    },
  }
end

lspconfig.sema.setup({})
```

## Requirements

- **Neovim** with [`nvim-treesitter`](https://github.com/nvim-treesitter/nvim-treesitter)
  (for highlighting).
- **The `sema` binary** on your `PATH` (for LSP, and to run Sema programs).
  Install from [sema-lang.com](https://sema-lang.com) — e.g. `cargo install sema`
  or `npm install -g @sema-lang/cli`.

## Roadmap

- **Upstream `:TSInstall sema` without this plugin** — a PR to
  [`nvim-treesitter/nvim-treesitter`](https://github.com/nvim-treesitter/nvim-treesitter)
  adding `sema` to `lua/nvim-treesitter/parsers.lua` (with the `queries/sema/*.scm`
  copied in), so the parser installs from the registry directly.
- **Upstream `lspconfig.sema`** — a PR to
  [`neovim/nvim-lspconfig`](https://github.com/neovim/nvim-lspconfig) adding
  `lsp/sema.lua`, so the LSP config ships out of the box.

## Links

- **Homepage**: [sema-lang.com](https://sema-lang.com)
- **Playground**: [sema.run](https://sema.run)
- **Language**: [github.com/HelgeSverre/sema](https://github.com/HelgeSverre/sema)
- **Grammar**: [github.com/sema-lisp/tree-sitter-sema](https://github.com/sema-lisp/tree-sitter-sema)
