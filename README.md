# Sema for Neovim

Neovim support for [Sema](https://sema-lang.com) (`.sema`) — a Lisp dialect with
first-class LLM primitives. Provides tree-sitter syntax highlighting (via
[`tree-sitter-sema`](https://github.com/HelgeSverre/tree-sitter-sema)) and LSP
integration with the built-in `sema lsp` server.

- **Homepage**: [sema-lang.com](https://sema-lang.com)
- **Source**: [github.com/HelgeSverre/sema](https://github.com/HelgeSverre/sema)

This directory is a self-contained Neovim plugin: it detects the `sema`
filetype, registers the tree-sitter parser with `nvim-treesitter`, and ships the
highlight queries. It does **not** auto-start the LSP — wire that up yourself
(see below) so it stays out of your way if you only want highlighting.

## Install

### lazy.nvim

```lua
{
  "HelgeSverre/sema",
  -- only load the Neovim plugin subdirectory of the monorepo
  config = function(plugin)
    vim.opt.rtp:append(plugin.dir .. "/editors/nvim")
  end,
  ft = "sema",
  dependencies = { "nvim-treesitter/nvim-treesitter" },
}
```

Then `:TSInstall sema` once to fetch and compile the grammar. Highlighting works
on the next `.sema` buffer.

### packer.nvim

```lua
use({
  "HelgeSverre/sema",
  rtp = "editors/nvim",
  requires = { "nvim-treesitter/nvim-treesitter" },
})
```

### Manual

Symlink or copy `editors/nvim/` onto your `runtimepath` (e.g. into
`~/.config/nvim/pack/plugins/start/sema/`), then `:TSInstall sema`.

## LSP

Sema ships a built-in language server (`sema lsp`): completions, hover,
go-to-definition, references, rename, signature help, diagnostics, document
symbols, and code lens.

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

Until an upstream `sema` config ships (see below), register it inline:

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

## Contributing to the registries (maintainers)

These make `:TSInstall sema` and `lspconfig.sema` work out-of-the-box for
everyone, without this plugin:

**1. nvim-treesitter** — PR to
[`nvim-treesitter/nvim-treesitter`](https://github.com/nvim-treesitter/nvim-treesitter),
adding to `lua/nvim-treesitter/parsers.lua` (master branch):

```lua
sema = {
  install_info = {
    url = "https://github.com/HelgeSverre/tree-sitter-sema",
    files = { "src/parser.c", "src/scanner.c" },
    branch = "main",
  },
  maintainers = { "@HelgeSverre" },
  tier = 3,
},
```

Copy `queries/sema/*.scm` into the nvim-treesitter `queries/sema/` directory in
the same PR.

**2. nvim-lspconfig** — PR to
[`neovim/nvim-lspconfig`](https://github.com/neovim/nvim-lspconfig) adding
`lsp/sema.lua`:

```lua
return {
  cmd = { "sema", "lsp" },
  filetypes = { "sema" },
  root_markers = { "sema.toml", ".git" },
}
```

**3. mason.nvim** (optional) — to distribute the `sema` binary itself, submit a
package to [`mason-org/mason-registry`](https://github.com/mason-org/mason-registry)
pointing at the crates.io / npm release.
