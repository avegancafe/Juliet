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

## Theme Assets

Theme files and color definitions stored in `etc/themes/`.

## Adding Bamboo to a New App

1. Check if app supports Bamboo directly
2. If not, find the closest equivalent or port the colors:
   - Background: dark green-tinted
   - Foreground: soft white
   - Accent: green highlights
3. Document the theme setting in the app's config
