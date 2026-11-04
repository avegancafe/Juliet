# Theming

## Primary Theme: Bamboo

Bamboo theme is applied consistently across all applications.

## Font

**Iosevka Nerd Font Mono** - Used for terminals and editors.

## Themed Applications

| Application | Config Location | Theme Setting |
|-------------|-----------------|---------------|
| Neovim | `symlinked/config/nvim/fnl/Juliet/plugins/theme.fnl` | Bamboo colorscheme |
| Ghostty | `symlinked/config/ghostty/config` | Bamboo theme |
| Helix | `symlinked/config/helix/config.toml` | Bamboo theme |
| Btop | `symlinked/config/btop/btop.conf` | Bamboo theme |
| Rex | `symlinked/config/ghostty/themes/{bamboo,bamboo_multiplex,bamboo_light}` (shared with Ghostty; `bamboo_multiplex` and `bamboo_light` are copied unchanged from bamboo.nvim's `extras/ghostty/`) | Dark = `bamboo`, light = `bamboo_light`, `bamboo_multiplex` is available. Import each file with `rex -C <client> do client.theme.import path=$HOME/.config/ghostty/themes/<name>`. The import selects each theme for the mode that matches its brightness (dark or light), so the last dark import wins. Import `bamboo` last, or select it after the imports with `rex -C <client> do client.theme.change name=bamboo`. Rex keeps the themes in its app settings (`defaults read com.superlogical.rex Workspace.darkThemeID`), not in a dotfile, and `init.lua` has no theme API, so run the import again on a new machine |
| Noctalia | `symlinked/config/noctalia/palettes/Bamboo.json` | Custom palette; selected via `[theme] source = "custom"`, `custom_palette = "Bamboo"` in `config.toml` (GUI changes land in `~/.local/state/noctalia/settings.toml` and override it). The bar is three floating pills: transparent `[bar.default]` with one `[[bar.default.capsule_group]]` per lane; rearranging widgets in the GUI writes lanes to the state file, which then overrides the `group:` lanes |

## Theme Assets

Theme files and color definitions stored in `etc/themes/`.

## Adding Bamboo to a New App

1. Check if app supports Bamboo directly
2. If not, find the closest equivalent or port the colors:
   - Background: dark green-tinted
   - Foreground: soft white
   - Accent: green highlights
3. Document the theme setting in the app's config
