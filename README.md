<div align="center">

<img src="https://sema-lang.com/logo.svg" alt="Sema" height="64">

# Sema for Neovim

**[Sema](https://sema-lang.com) support for [Neovim](https://neovim.io)** — a Lisp with first-class LLM primitives.

[![CI](https://img.shields.io/github/actions/workflow/status/sema-lisp/sema.nvim/ci.yml?branch=main&label=CI&logo=github)](https://github.com/sema-lisp/sema.nvim/actions)
[![License](https://img.shields.io/github/license/sema-lisp/sema.nvim?color=c8a855)](LICENSE)
[![Website](https://img.shields.io/badge/website-sema--lang.com-c8a855)](https://sema-lang.com)

</div>

Neovim support for Sema (`.sema`) source files: filetype detection, tree-sitter syntax highlighting (via [`tree-sitter-sema`](https://github.com/sema-lisp/tree-sitter-sema)), and opt-in wiring for the built-in `sema lsp` language server.

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
- **LSP (automatic)** — the plugin registers and enables the built-in language
  server (`sema lsp`) on Neovim ≥ 0.11; open a `.sema` file and it attaches with
  no config. Completions, hover, go-to-definition, references, rename, signature
  help, diagnostics, document symbols, and code lens. No `nvim-lspconfig`
  dependency.
- **Debugging (DAP, optional)** — if [`nvim-dap`](https://github.com/mfussenegger/nvim-dap)
  is installed, the plugin registers the `sema` debug adapter (`sema dap`) with a
  "Launch Sema file" configuration.

## Language server

Automatic — no setup. Opening a `.sema` file starts `sema lsp` (resolved from
your `PATH`). On Neovim ≥ 0.11 this uses the native `vim.lsp.config` /
`vim.lsp.enable`; on older versions the plugin falls back to a `FileType`
autocmd. To customize (e.g. disable a capability), override with your own
`vim.lsp.config("sema", …)` after the plugin loads.

## Debugging (DAP)

Install [`nvim-dap`](https://github.com/mfussenegger/nvim-dap); the plugin then
registers the adapter automatically. Set a breakpoint
(`:lua require('dap').toggle_breakpoint()`) and start with
`:lua require('dap').continue()` → **Launch Sema file**. The adapter runs
`sema dap` over stdio.

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

- **Website** — [sema-lang.com](https://sema-lang.com)
- **Playground** — [sema.run](https://sema.run)
- **Documentation** — [sema-lang.com/docs](https://sema-lang.com/docs/)
- **Grammar** — [tree-sitter-sema](https://github.com/sema-lisp/tree-sitter-sema)
- **Repository** — [sema-lisp/sema.nvim](https://github.com/sema-lisp/sema.nvim)

## License

[MIT](LICENSE) © [Helge Sverre](https://github.com/HelgeSverre)
