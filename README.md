# roto-rooter.nvim 🔧

Automatic project root detection for Neovim

**roto-rooter.nvim** automatically changes your working directory to the project root when you open files, keeping you properly rooted in the right place. No more manual `:cd` commands or getting lost in deep directory structures.

## ✨ Features

- 🎯 **Smart root detection** - Finds project roots using configurable patterns (`.git`, `package.json`, `Cargo.toml`, etc.)
- 💻 **Window-local by default** - Each window can have its own working directory
- ⚡ **Zero configuration** - Works out of the box with sensible defaults
- ⚙️ **Highly configurable** - Customize patterns, behavior, and fallbacks
- 🔀 **Easy toggle** - Enable/disable on the fly with simple commands
- 📁 **Fallback options** - Choose what happens when no project root is found

## 📦 Installation

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "yourusername/roto-rooter.nvim",
  opts = {}
}
```

### Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  "yourusername/roto-rooter.nvim",
  config = function()
    require("roto-rooter").setup()
  end
}
```

## 🚀 Usage

### Basic Setup

```lua
-- Use defaults - works great out of the box
require("roto-rooter").setup()
```

### Advanced Configuration

```lua
require("roto-rooter").setup({
  -- Use global 'cd' instead of window-local 'lcd'
  global = false,

  -- Fallback to original directory if no project root found
  fallback_to_current = false,

  -- Custom project root patterns (replaces defaults)
  patterns = { ".git", "package.json", "Makefile" },

  -- Or extend the default patterns
  extend_defaults = { ".projectroot", "docker-compose.yml" },
})
```

### Default Patterns

roto-rooter.nvim looks for these patterns in order of priority:

1. `.git` - Git repository
2. `package.json` - Node.js project
3. `Cargo.toml` - Rust project
4. `go.mod` - Go module
5. `Makefile` - Make-based project
6. `pyproject.toml` - Python project

## 🔀 Commands

| Command | Description |
|---------|-------------|
| `:RREnable` | Enable automatic root detection |
| `:RRDisable` | Disable automatic root detection |
| `:RRToggle` | Toggle on/off |

## ⚙️ Configuration Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `global` | boolean | `false` | Use `cd` instead of `lcd` (affects entire Neovim session) |
| `fallback_to_current` | boolean | `false` | Fallback to original directory if no root found |
| `patterns` | table | See above | Custom list of project root patterns |
| `extend_defaults` | table | `nil` | Additional patterns to add to defaults |

## 💡 Use Cases

### Perfect for:
- 🔍 **File navigation** - Always in the right context for fuzzy finders
- 🏗️ **Build commands** - `:!npm test`, `:!cargo run` work from project root
- 📊 **Status lines** - Show current project in lualine/other status bars
- 🌳 **File trees** - Consistent project scope

### Integrates well with:
- [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) - File searching
- [lualine.nvim](https://github.com/nvim-lualine/lualine.nvim) - Status line display
- [nvim-tree](https://github.com/nvim-tree/nvim-tree.lua) - File explorer

## 🎨 Lualine Integration

Show your current project directory in lualine:

```lua
require('lualine').setup({
  sections = {
    lualine_x = {
      {
        function()
          return vim.fn.fnamemodify(vim.fn.getcwd(0), ':t')
        end,
        icon = '📁'
      }
    }
  }
})
```

## 🤔 Why roto-rooter?

Just like the plumbing service clears blocked pipes, **roto-rooter.nvim** clears the path to your project root automatically. No more getting stuck in the wrong directory!

## 🐛 Troubleshooting

**Plugin not working?**
- Check if patterns match your project structure
- Use `:RRToggle` to verify it's enabled
- Try adding debug prints to see what's happening

**Directory not changing?**
- Make sure you have one of the default patterns in your project
- Consider adding custom patterns for your workflow
- Check if another plugin is interfering

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

MIT License - see [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

Inspired by the need for better directory management in Neovim and the simplicity of "it should just work."