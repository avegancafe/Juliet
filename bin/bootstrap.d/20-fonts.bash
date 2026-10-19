# shellcheck shell=bash disable=SC2034  # globals are shared across modules
# Sourced by bin/juliet-bootstrap (never run directly).
# fonts: Iosevka Nerd Font Mono plus the fonts vendored in etc/fonts.

category fonts rlog "🔤 Installing fonts..." \
  "Install fonts (Iosevka Nerd Font Mono + the vendored ones in etc/fonts)?" \
  setup-fonts

# Pinned Nerd Fonts release used for fonts too large to vendor (Iosevka).
NERD_FONTS_VERSION="v3.4.0"

# User-writable font directory for the current OS.
font-dir() {
  if is-macos; then
    echo "$HOME/Library/Fonts"
  else
    echo "$HOME/.local/share/fonts"
  fi
}

setup-fonts() {
  substep "Installing fonts..."
  local changed=0
  local dest="$(font-dir)/Juliet"
  mkdir -p "$dest"

  # 1. Vendored fonts (flattened into dest; fontconfig/CoreText recurse anyway)
  local vendored="$HOME/.config/Juliet/etc/fonts"
  if [[ -d "$vendored" ]]; then
    local font
    while IFS= read -r -d '' font; do
      cmp -s "$font" "$dest/$(basename "$font")" && continue
      cp -f "$font" "$dest/" && changed=1
    done < <(find "$vendored" -type f \( -iname '*.ttf' -o -iname '*.otf' \) -print0)
  fi

  # 2. Iosevka Nerd Font Mono (download + extract the four core Mono weights)
  if [[ ! -f "$dest/IosevkaNerdFontMono-Regular.ttf" ]]; then
    changed=1
    local url="https://github.com/ryanoasis/nerd-fonts/releases/download/${NERD_FONTS_VERSION}/Iosevka.zip"
    local tmp
    tmp="$(mktemp -d)"
    if spin "Downloading Iosevka Nerd Font Mono (${NERD_FONTS_VERSION}, ~374MB, one-time)..." \
         curl -fL --retry 2 -o "$tmp/Iosevka.zip" "$url"; then
      unzip -o -j "$tmp/Iosevka.zip" \
        'IosevkaNerdFontMono-Regular.ttf' \
        'IosevkaNerdFontMono-Bold.ttf' \
        'IosevkaNerdFontMono-Italic.ttf' \
        'IosevkaNerdFontMono-BoldItalic.ttf' \
        -d "$dest" > /dev/null \
        || bootstrap_error "Failed to extract Iosevka Nerd Font Mono from Iosevka.zip"
    else
      bootstrap_error "Failed to download Iosevka Nerd Font Mono" \
        "Fetch manually from https://github.com/ryanoasis/nerd-fonts/releases/tag/${NERD_FONTS_VERSION}"
    fi
    rm -rf "$tmp"
  fi

  # 3. Refresh the font cache (macOS picks fonts up automatically and may not
  # ship fc-cache, so only run it when present).
  if (( changed )) && command -v fc-cache &> /dev/null; then
    fc-cache -f "$(font-dir)" > /dev/null 2>&1 || true
  fi
  (( changed )) || unchanged "already installed"
  return 0
}
