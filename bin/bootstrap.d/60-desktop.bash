# shellcheck shell=bash disable=SC2034  # globals are shared across modules
# Sourced by bin/juliet-bootstrap (never run directly).
# desktop (Fedora): greeter, input remap, Plasma removal, crash hygiene,
# nvidia, fingerprint reader.

# Order matters here: sddm must become the display manager before deplasma
# removes plasma-login-manager (or there's no way to log in), and fingerprint
# edits /etc/pam.d/sddm, which is only worth doing once sddm is the DM.
category desktop log "🖥️ Configuring desktop..." "Configure desktop?" \
  setup-sddm setup-deplasma setup-undms setup-coredump-limits \
  setup-crash-purge setup-nvidia-secureboot setup-nvidia-powermgmt \
  setup-keyd setup-fingerprint

setup-sddm() {
  if ! is-fedora; then
    return
  fi

  if ! command -v sddm &> /dev/null; then
    return
  fi

  # sddm needs a Wayland greeter session to launch niri. Every provider of
  # sddm-greeter-displayserver conflicts with every other one, so this can't
  # live in the DNFfile: the KDE spin preinstalls sddm-wayland-plasma, and
  # asking for sddm-wayland-generic on top of it makes the whole transaction
  # unresolvable. Any provider works for our purposes, so only install the
  # generic one when the machine has none.
  if ! rpm -q --whatprovides sddm-greeter-displayserver &> /dev/null; then
    substep "Installing sddm Wayland greeter session..."
    sudo dnf install -y sddm-wayland-generic \
      || bootstrap_error "Failed to install sddm-wayland-generic" \
        "Install it manually: sudo dnf install sddm-wayland-generic"
  fi

  # Make sddm the active display manager. Fedora's KDE spin installs
  # plasma-login-manager (plasmalogin.service) and enables it; this machine
  # runs niri, so sddm takes over as the greeter. display-manager.service is a
  # symlink to whichever DM is enabled, so enabling sddm repoints it.
  # This must happen BEFORE setup-deplasma removes plasma-login-manager,
  # otherwise the box is left with no way to log in graphically.
  if [[ "$(basename "$(readlink -f /etc/systemd/system/display-manager.service 2>/dev/null)" 2>/dev/null)" != "sddm.service" ]]; then
    substep "Making sddm the display manager..."
    if systemctl list-unit-files plasmalogin.service &> /dev/null; then
      sudo systemctl disable plasmalogin.service &> /dev/null || true
    fi
    sudo systemctl enable sddm.service \
      || bootstrap_error "Failed to enable sddm.service" \
        "Enable it manually before rebooting: sudo systemctl enable sddm.service"
  fi

  substep "Setting up SDDM theme..."

  THEME_SRC="$HOME/.config/Juliet/etc/sddm-themes/juliet"
  THEME_DEST="/usr/share/sddm/themes/juliet"

  if [[ ! -d "$THEME_SRC" ]]; then
    unchanged "no theme in repo"
    return
  fi

  # The theme renders solid black by default, matching the hyprlock lock
  # screen, so this wallpaper is unused until theme.conf sets
  # `background=background.png`. Copied anyway so making that switch is a
  # one-word edit rather than a hunt for the file.
  local wallpaper="$HOME/.config/Juliet/etc/wallpaper/my-neighbor-totoro-sunflowers.png"

  # Recopy only when the installed theme differs from the repo's.
  if diff -rq --exclude=background.png "$THEME_SRC" "$THEME_DEST" &> /dev/null \
    && cmp -s "$wallpaper" "$THEME_DEST/background.png"; then
    unchanged "theme up to date"
  else
    substep "Installing Juliet SDDM theme..."
    sudo rm -rf "$THEME_DEST"
    sudo cp -r "$THEME_SRC" "$THEME_DEST"
    sudo cp "$wallpaper" "$THEME_DEST/background.png"
    sudo chmod -R 755 "$THEME_DEST"
    sudo find "$THEME_DEST" -type f -exec chmod 644 {} \;
  fi

  # Select the theme. Written whenever the content differs rather than only when
  # the file is absent: a create-once guard can't converge if the file drifts
  # (hand-edited, or left over from an earlier theme name), which would leave the
  # theme installed but not actually selected.
  # CursorTheme is what exports XCURSOR_THEME into the greeter, and without it
  # the login screen has no visible mouse pointer at all. The greeter runs under
  # `weston --shell=kiosk` (sddm-wayland-generic), and on Wayland the pointer
  # image is drawn entirely by the client — weston's kiosk shell paints no
  # fallback — so a greeter that can't load a cursor theme renders nothing while
  # the mouse still works. The KDE spin's kde_settings.conf used to supply this;
  # setup-deplasma takes that file with it, so Juliet has to own it now.
  # The selection itself lives in etc/sddm/juliet.conf.
  substep "Configuring SDDM to use the Juliet theme..."
  install-system-file "$JULIET_DIR/etc/sddm/juliet.conf" /etc/sddm.conf.d/juliet.conf
  [[ $? -eq 1 ]] && unchanged "already selected"

  # The cursor theme named above has to actually exist for the greeter, which
  # runs as the sddm user and only searches system icon dirs.
  if [[ ! -d /usr/share/icons/Adwaita/cursors ]]; then
    warn "Cursor theme Adwaita is missing — the greeter will have an invisible mouse pointer. Install adwaita-cursor-theme."
  fi
}

# keyd gives the Super key (leftmeta) a dual role: hold = the Mod modifier for
# niri, tap = F13 (bound to toggle the noctalia Control Center). keyd is a root
# daemon that reads /etc/keyd, so its config can't be a stow symlink in $HOME —
# copy the tracked config in and (re)load the service instead.
setup-keyd() {
  if ! is-fedora; then
    return
  fi

  # keyd comes from the DNFfile (packages step); skip cleanly if it isn't here.
  if ! command -v keyd &> /dev/null; then
    return
  fi
  substep "Setting up keyd (dual-role Super: hold=Mod, tap=noctalia menu)..."

  install-system-file "$JULIET_DIR/etc/keyd/default.conf" /etc/keyd/default.conf
  local rc=$?
  (( rc == 2 )) && return

  if (( rc == 1 )) \
    && systemctl is-enabled --quiet keyd && systemctl is-active --quiet keyd; then
    unchanged "config current, service running"
    return
  fi

  sudo systemctl enable --now keyd \
    || bootstrap_error "Failed to enable the keyd service" \
      "Enable it manually: sudo systemctl enable --now keyd"
  # Re-runs: pick up config changes without a restart (no-op on first enable).
  sudo keyd reload &> /dev/null || true
}

# The Goodix 27c6:533c reader in this XPS 15 9500 is a match-on-chip sensor that
# Fedora's libfprint cannot drive: the open goodixmoc driver doesn't cover the
# 53xc family, so a stock install enumerates the hardware fine but fprintd still
# reports "No devices available". The only working driver is Goodix's
# proprietary TOD (Touch OEM Driver) blob, and that needs libfprint rebuilt with
# TOD support — a package that REPLACES Fedora's stock libfprint.
#
# Two COPRs, deliberately, because neither is complete on its own:
#   antiderivative/libfprint-tod-goodix-0.0.9 supplies libfprint-tod, genuinely
#     rebuilt for f44. Its own goodix package is excluded: that one is the 550a
#     driver, whose device table covers 5117/5381/5750 but NOT 533c.
#   manciukic/libfprint-tod-goodix supplies libfprint-tod-goodix 0.0.6, the
#     "53xc" blob that does list 27c6:533c. Its libfprint-tod is excluded: that
#     chroot only ever got fc40 binaries forked forward to f44.
# Pairing the two is safe — the blob links against nothing but
# libfprint-2-tod.so.1 and glibc, so the fc40 build runs fine on the fc44 core.
# The excludepkgs pins matter beyond first install: without them a later `dnf
# upgrade` pulls goodix 0.0.9 over 0.0.6 and silently kills the sensor.
#
# To undo all of this:
#   sudo dnf swap libfprint-tod libfprint
#   sudo dnf copr disable antiderivative/libfprint-tod-goodix-0.0.9
#   sudo dnf copr disable manciukic/libfprint-tod-goodix
# The fingerprint COPRs are enabled here rather than in the DNFfile because
# they only belong on machines with the sensor. sync-copr-repos counts them as
# declared on such machines so it doesn't flag them as strays.
FINGERPRINT_COPRS=(antiderivative/libfprint-tod-goodix-0.0.9 manciukic/libfprint-tod-goodix)

# Read from sysfs rather than lsusb so this doesn't depend on usbutils.
has-goodix-533c() {
  local dev
  for dev in /sys/bus/usb/devices/*/; do
    if [[ "$(cat "$dev/idVendor" 2>/dev/null)" == "27c6" \
      && "$(cat "$dev/idProduct" 2>/dev/null)" == "533c" ]]; then
      return 0
    fi
  done
  return 1
}

setup-fingerprint() {
  if ! is-fedora; then
    return
  fi

  # Only meaningful on hardware carrying this exact sensor.
  if ! has-goodix-533c; then
    return
  fi

  if ! rpm -q libfprint-tod-goodix &> /dev/null; then
    substep "Installing the Goodix TOD fingerprint driver..."

    local repo
    for repo in "${FINGERPRINT_COPRS[@]}"; do
      if ! dnf copr list 2>/dev/null | grep -q "$repo"; then
        sudo dnf copr enable -y "$repo" \
          || bootstrap_error "Failed to enable COPR $repo" \
            "Enable it manually: sudo dnf copr enable -y $repo"
      fi
    done

    # Pin each COPR to the half it is authoritative for. The repo files are
    # located by their baseurl rather than by filename so this doesn't depend on
    # how dnf spells the generated _copr:... filename.
    local pin_repo pin_excludes repo_file
    for pin_repo in \
      "antiderivative/libfprint-tod-goodix-0.0.9=libfprint-tod-goodix" \
      "manciukic/libfprint-tod-goodix=libfprint-tod,libfprint-tod-devel"; do
      pin_excludes="${pin_repo#*=}"
      pin_repo="${pin_repo%%=*}"
      repo_file="$(grep -rlsF "results/${pin_repo}/" /etc/yum.repos.d/ 2>/dev/null | head -1)"
      if [[ -z "$repo_file" ]]; then
        bootstrap_error "Could not find the .repo file for COPR $pin_repo" \
          "Add 'excludepkgs=$pin_excludes' to it by hand under /etc/yum.repos.d"
        continue
      fi
      if ! grep -q "^excludepkgs=" "$repo_file"; then
        sudo sed -i "/^\[/a excludepkgs=$pin_excludes" "$repo_file" \
          || bootstrap_error "Failed to pin COPR $pin_repo" \
            "Add 'excludepkgs=$pin_excludes' to $repo_file by hand"
      fi
    done

    # libfprint-tod Obsoletes only `libfprint = 1.94.5`, so it does not supersede
    # Fedora's newer libfprint on its own, and the two both own five files
    # (libfprint-2.so.2 among them). swap replaces it in a single transaction
    # instead of failing the install on the file conflict. Nothing but fprintd
    # depends on libfprint, and fprintd needs only the libfprint-2.so.2 soname,
    # which libfprint-tod provides — so the swap is contained.
    if ! rpm -q libfprint-tod &> /dev/null; then
      sudo dnf swap -y libfprint libfprint-tod \
        || bootstrap_error "Failed to swap libfprint for libfprint-tod" \
          "Run it manually: sudo dnf swap -y libfprint libfprint-tod"
    fi
    sudo dnf install -y libfprint-tod-goodix \
      || bootstrap_error "Failed to install libfprint-tod-goodix" \
        "Run it manually: sudo dnf install -y libfprint-tod-goodix"

    # fprintd enumerates drivers at startup, so a daemon already running won't
    # see the new blob. It is D-Bus activated, so stopping is enough: the next
    # call starts a fresh one that picks the driver up.
    sudo systemctl stop fprintd.service &> /dev/null || true
  fi

  # SDDM's PAM stack includes password-auth, which authselect deliberately keeps
  # fingerprint-free (it also serves remote logins, where a reader makes no
  # sense). system-auth already gets pam_fprintd from `authselect ...
  # with-fingerprint`, which covers sudo and console login, so only the greeter
  # needs wiring up by hand.
  #
  # sufficient, and placed first: a swipe logs you in, and any failure — no
  # enrolled print, reader disabled in BIOS, driver broken by an update — falls
  # straight through to the password prompt rather than locking you out.
  #
  # max-tries and timeout are load-bearing, not tuning. SDDM runs exactly one
  # PAM conversation at a time, and pam_fprintd holds it open while waiting on
  # the reader. With the stock retry count, a typed password therefore does
  # NOTHING until the fingerprint attempts are exhausted — every Enter is
  # discarded and the journal fills with "Existing authentication ongoing,
  # aborting". Capping it at a single short attempt keeps swipe-to-login while
  # letting the password through quickly. (pam_fprintd clamps a timeout below
  # its own floor and logs that it did, so a low value is safe.)
  local pam_sddm="/etc/pam.d/sddm"
  local fprintd_line="auth        sufficient    pam_fprintd.so max-tries=1 timeout=10"
  if [[ -f "$pam_sddm" ]]; then
    # Keep a pristine copy: /etc/pam.d/sddm is package-owned, and a botched auth
    # stack is only fixable from a TTY.
    sudo cp -n "$pam_sddm" "$pam_sddm.juliet-orig" &> /dev/null || true

    if ! grep -q "pam_fprintd.so" "$pam_sddm"; then
      substep "Enabling fingerprint auth at the SDDM greeter..."
      sudo sed -i \
        "s|^auth\([[:space:]]\{1,\}\)substack\([[:space:]]\{1,\}\)password-auth|$fprintd_line\nauth\1substack\2password-auth|" \
        "$pam_sddm" \
        || bootstrap_error "Failed to add pam_fprintd to $pam_sddm" \
          "Add this above the password-auth line: $fprintd_line"
    elif [[ "$(grep -m1 'pam_fprintd\.so' "$pam_sddm")" != "$fprintd_line" ]]; then
      # Converge a line written by an older bootstrap (or by hand) onto the
      # current options, instead of leaving it stale because "some pam_fprintd
      # line exists".
      substep "Updating the SDDM fingerprint PAM options..."
      sudo sed -i "s|^.*pam_fprintd\.so.*\$|$fprintd_line|" "$pam_sddm" \
        || bootstrap_error "Failed to update pam_fprintd options in $pam_sddm" \
          "Set the line to: $fprintd_line"
    fi
  fi
}

# Plasma components that are dead weight — or actively harmful — on a machine
# running niri. This box was installed from the Fedora KDE spin, so it carries
# a full Plasma stack it never uses.
#
# The motivating failure: drkonqi (Plasma's crash handler) segfaults outside a
# Plasma session, and systemd-coredump re-invokes it on every crash, forming a
# feedback loop. Left alone it produced 106,222 coredumps / 4.1GB and pinned
# the CPU package at 100°C for ten days (2026-07-15 → 2026-07-25).
#
# SCOPE IS DELIBERATELY LIMITED. plasma-desktop is a dnf *protected* package
# (/etc/dnf/protected.d/plasma-desktop.conf, owned by
# fedora-release-identity-kde-desktop) and it transitively pins
# plasma-workspace, plasma-workspace-libs, plasma-integration,
# plasma-systemsettings, plasma-activities{,-stats}, plasma-keyboard,
# plasma-breeze, plasma-lookandfeel-fedora, polkit-kde and
# xdg-desktop-portal-kde. Removing any of those first requires swapping the
# release identity (`dnf swap fedora-release-identity-kde-desktop
# fedora-release-identity-basic`), which rewrites /usr/lib/os-release and the
# systemd presets. That's a bigger, upgrade-path-affecting change and is
# deliberately NOT done here — the crash loop doesn't need it.
#
# plasma-integration-qt5 is excluded for a different reason: it drags the
# entire Qt5 stack out with it, which would take vlc (a DNFfile package) along.
#
# This list was verified with `dnf remove --assumeno`: 61 packages, ~354MB,
# and no DNFfile package touched. Re-verify the same way before extending it.
PLASMA_CRUFT=(
  plasma-drkonqi              # the crash-looping culprit
  plasma-discover             # + its flatpak/kns/libs/notifier/packagekit subpackages
  plasma-welcome              # + plasma-welcome-fedora
  plasma-disks
  plasma-thunderbolt          # pulls bolt; no TB devices enrolled on noelle
  plasma-vault                # pulls cryfs/gocryptfs/fuse-encfs
  plasma-systemmonitor
  plasma-milou
  plasma-browser-integration
  plasma-print-manager        # + -libs
  plasma-pa
  plasma-nm                   # + 6 VPN applets; pulls openvpn/openconnect/vpnc/
                              # pptp/libreswan. NetworkManager itself is kept,
                              # and noelle has no VPN connections configured.
  plasma-setup
  plasma-desktop-doc
  plasma-workspace-wallpapers
)

# KDE PIM — the spin's mail/calendar/contacts suite. Not Plasma proper, hence a
# separate list, but the same class of leftover.
#
# kalendarac ("Calendar Reminders", from akonadi-calendar) autostarted and died
# at every login with a symbol lookup error: messagelib wants
# setFormatTypes(const QFlags<...>&) while ktextaddons-qt6 2.0.1 ships it by
# value. The soname stayed .so.1 across that ABI break, so RPM's dependency
# check never caught it — nothing to fix locally, and none of this suite is used
# here (no mail account, calendar, or address book was ever configured).
#
# akonadi-calendar drags the rest of the suite out with it: calendarsupport,
# eventviews, incidenceeditor, kdepim-addons, kdepim-runtime, kmail, kontact,
# korganizer and their -libs. akregator and kaddressbook are NOT in that
# closure, so they're listed explicitly — leaving either behind keeps the whole
# akonadi server stack alive, which defeats the point.
KDEPIM_CRUFT=(
  akonadi-calendar
  akregator
  kaddressbook
)

setup-deplasma() {
  if ! is-fedora; then
    return
  fi

  # Build the removal list from what's actually installed, so re-runs are a
  # cheap no-op and a partially-removed system still converges.
  local targets=()
  local pkg
  for pkg in "${PLASMA_CRUFT[@]}" "${KDEPIM_CRUFT[@]}"; do
    rpm -q "$pkg" &> /dev/null && targets+=("$pkg")
  done

  # plasma-login-manager is the Fedora KDE spin's display manager (there is no
  # sddm on a stock KDE install). Only remove it once sddm has actually taken
  # over, or the machine is left with no graphical login. setup-sddm runs first
  # in run-desktop and does that switch; this guard is the backstop.
  if rpm -q plasma-login-manager &> /dev/null; then
    local active_dm
    active_dm="$(basename "$(readlink -f /etc/systemd/system/display-manager.service 2>/dev/null)" 2>/dev/null)"
    if [[ "$active_dm" == "sddm.service" ]]; then
      targets+=(plasma-login-manager)
    else
      warn "Keeping plasma-login-manager: sddm is not the active display manager (found: ${active_dm:-none})."
    fi
  fi

  if [[ ${#targets[@]} -eq 0 ]]; then
    return
  fi

  substep "Removing ${#targets[@]} unused Plasma / KDE PIM packages..."
  sudo dnf remove -y "${targets[@]}" \
    || bootstrap_error "Failed to remove the Plasma / KDE PIM cruft" \
      "Inspect the transaction manually: sudo dnf remove --assumeno ${targets[*]}"

  # With the PIM suite gone, akonadi's database under ~/.local/share/akonadi is
  # orphaned — on this machine ~113MB of an empty MariaDB instance the server
  # creates on first start. Deliberately NOT deleted automatically: telling an
  # empty akonadi from one holding a real local mail store means inspecting the
  # resource data, and no heuristic worth trusting fits in a bootstrap step. A
  # fresh machine never accumulates it, so it isn't reproducible state either.
  # Report it and let the operator decide.
  if [[ -d "$HOME/.local/share/akonadi" ]]; then
    notice "Orphaned akonadi DB left at ~/.local/share/akonadi ($(du -sh "$HOME/.local/share/akonadi" 2> /dev/null | cut -f1))."
    notice "If no mail/calendar was ever configured: rm -rf ~/.local/share/akonadi ~/.config/akonadi"
  fi

  # drkonqi's user units go with the package; drop the mask symlinks used to
  # muzzle the crash loop while it was still installed.
  rm -f "$HOME/.config/systemd/user/drkonqi-coredump-launcher.socket" \
        "$HOME/.config/systemd/user/drkonqi-coredump-pickup.service" \
        "$HOME/.config/systemd/user/drkonqi-coredump-cleanup.timer"

  # Restore the stock coredump handler. Breaking the loop by hand means
  # pointing kernel.core_pattern at /bin/false; with drkonqi gone,
  # systemd-coredump is safe again. sysctl --system re-reads the shipped
  # /usr/lib/sysctl.d/50-coredump.conf.
  sudo sysctl --system &> /dev/null || true
}

# DankMaterialShell (dms) was the niri shell before noctalia, and it does not
# step aside quietly: its user unit is enabled independently of niri's
# spawn-at-startup, and it claims the org.freedesktop.Notifications bus name, so
# leaving it installed means two bars and dms owning notifications no matter
# what niri launches. Noctalia is the shell Juliet configures (DNFfile +
# symlinked/config/noctalia + spawn-at-startup in the niri config), so retire
# dms rather than leaving the two to race.
setup-undms() {
  if ! is-fedora; then
    return
  fi

  # Never retire the old shell unless the replacement is actually installed —
  # otherwise a half-bootstrapped machine logs in to a bare compositor.
  if ! rpm -q noctalia &> /dev/null; then
    if rpm -q dms &> /dev/null; then
      warn "Keeping dms: noctalia is not installed yet (run the packages step first)."
    fi
    return
  fi

  # The unit was enabled by hand via `systemctl --user add-wants niri.service
  # dms.service`, which drops a symlink into niri.service.wants — not the
  # graphical-session.target.wants that [Install] declares. `disable` sweeps
  # every symlink it finds, but clear the wants dir explicitly so the switch
  # doesn't depend on that behaviour.
  if systemctl --user list-unit-files dms.service &> /dev/null; then
    if [[ "$(systemctl --user is-enabled dms.service 2> /dev/null)" != "disabled" ]]; then
      substep "Disabling the dms user service (noctalia is the niri shell)..."
      systemctl --user disable dms.service &> /dev/null \
        || warn "Could not disable dms.service — check: systemctl --user status dms.service"
    fi
  fi
  rm -f "$HOME"/.config/systemd/user/*.wants/dms.service
  systemctl --user daemon-reload &> /dev/null || true

  if rpm -q dms &> /dev/null; then
    substep "Removing dms (DankMaterialShell)..."
    sudo dnf remove -y dms \
      || bootstrap_error "Failed to remove dms" \
        "Inspect the transaction manually: sudo dnf remove --assumeno dms"
  fi

  # A dms already running in this session keeps going from its deleted binary
  # until logout; killing it mid-session would leave the user barless if
  # noctalia isn't up yet. Say so rather than doing it silently.
  if pgrep -x dms &> /dev/null; then
    notice "dms is still running in this session — it goes away at logout (or: systemctl --user stop dms.service)."
  fi

  # Its config is user data Juliet never managed, and telling a customised one
  # from an untouched one isn't a call bootstrap should make. Same reasoning as
  # the orphaned akonadi DB in setup-deplasma.
  if [[ -d "$HOME/.config/DankMaterialShell" ]]; then
    notice "Leftover dms config at ~/.config/DankMaterialShell — remove it by hand if you're done with dms."
  fi
}

# Cap how much disk systemd-coredump may consume. The drkonqi crash loop wrote
# 4.1GB of cores over ten days without anything noticing; the stock default
# (10% of the filesystem) is far too generous to act as a warning signal.
# This is a backstop, not the fix — see setup-deplasma for the actual cause.
setup-coredump-limits() {
  if ! is-fedora; then
    return
  fi

  # The caps themselves live in etc/coredump/juliet.conf.
  substep "Capping systemd-coredump disk usage..."
  install-system-file "$JULIET_DIR/etc/coredump/juliet.conf" \
    /etc/systemd/coredump.conf.d/juliet.conf
  [[ $? -eq 1 ]] && unchanged "caps current"
}

# Install fonts and refresh the font cache. Two sources:
#   1. Small TTF/OTFs vendored in etc/fonts (3270, Berkeley Mono, JetBrains
#      Mono, MonoLisa) — copied straight in.
#   2. Iosevka Nerd Font Mono — the primary terminal/editor font
#      (ghostty font-family, neovide guifont). Its v3.x weights are ~13MB
#      each, too big to vendor, so the four core Mono weights are pulled from
#      the pinned Nerd Fonts release and cached. The 374MB zip is only fetched
#      when Iosevka isn't already installed, so re-runs are cheap.
# Everything lands in <font-dir>/Juliet so the repo owns that subtree.
# The RPMFusion nvidia driver is compiled locally by akmods and signed with a
# key this machine generates itself (/etc/pki/akmods/certs/public_key.der). With
# Secure Boot on, the kernel refuses to load a module whose key isn't enrolled in
# the firmware's MOK store — and nothing announces it: nvidia-fallback.service
# quietly loads nouveau instead, so the display works and the breakage hides.
# The cost is real though — CUDA is dead despite the -cuda packages being
# installed, nouveau can't reclock Turing so the dGPU runs slow, and
# nvidia-powerd fails with "Allocate Root client failed". The only visible
# symptom was nvidia-settings failing at login with "NVIDIA driver is not
# loaded".
#
# `mokutil --import` only *stages* the key and sets a one-time password; the
# enrollment itself happens in the firmware's MOK Manager screen on the next
# boot and deliberately cannot be automated — physical presence is the point.
setup-nvidia-secureboot() {
  if ! is-fedora; then
    return
  fi
  if ! rpm -q akmod-nvidia &> /dev/null; then
    return
  fi
  # Secure Boot off means unsigned modules load fine — nothing to enroll.
  if ! mokutil --sb-state 2> /dev/null | grep -q 'SecureBoot enabled'; then
    return
  fi
  # The proprietary module loading at all proves the key is already trusted.
  # Tested via /proc/driver/nvidia rather than lsmod: the in-tree
  # nvidia-wmi-ec-backlight module (present on this Dell) loads as
  # "nvidia_wmi_ec_backlight" and would false-match a /^nvidia/ grep, silently
  # skipping enrollment forever. Only the real driver creates this directory.
  if [[ -d /proc/driver/nvidia ]]; then
    skip "nvidia driver loaded (MOK key already enrolled)"
    return
  fi
  # A key staged by an earlier run is still waiting on the reboot; importing
  # again would just overwrite the pending request with a new password.
  if mokutil --list-new 2> /dev/null | grep -q .; then
    warn "An akmods key is already staged. Reboot and complete MOK Manager to finish."
    return
  fi

  local key=/etc/pki/akmods/certs/public_key.der
  if ! sudo test -f "$key"; then
    bootstrap_error "akmods signing key not found at $key" \
      "Rebuild the module first: sudo akmods --force"
    return
  fi

  substep "Enrolling the akmods signing key so Secure Boot will load nvidia..."
  notice "mokutil asks for a one-time password — you re-enter it in MOK Manager on reboot."
  # Interactive (prompts twice for the password), so deliberately not wrapped in
  # spin() — the spinner would hide the prompt and look like a hang.
  if sudo mokutil --import "$key"; then
    warn "Reboot to finish: MOK Manager -> Enroll MOK -> Continue -> Yes -> that password."
  else
    bootstrap_error "Failed to stage the akmods key for MOK enrollment" \
      "Retry manually: sudo mokutil --import $key"
  fi
}

# The nvidia driver ships Runtime D3 disabled — /proc/driver/nvidia/gpus/*/power
# reports "Runtime D3 status: Disabled by default" — so on a laptop the dGPU
# stays powered from boot even when nothing is using it. Under nouveau this
# machine's GTX 1650 Ti idled in D3cold; the first boot on the proprietary
# driver had it in D0 for the entire session (runtime_suspended_time 0, active
# 555s). That is pure battery drain and heat on a box whose history includes a
# 100°C thermal runaway — so enabling RTD3 is part of switching drivers, not an
# optional extra.
#
# 0x02 is NVIDIA's most aggressive tier: power the GPU down, video memory
# included, once idle. It needs Turing or newer (this is TU117) plus hardware
# support, both confirmed here — "Video Memory Off: Supported" and "S0ix Platform
# Support: Supported". Where unsupported the driver simply won't engage it.
#
# The udev half already ships with the driver (80-nvidia-pm.rules sets
# power/control=auto on bind for PCI class 0x030200), and nvidia is not in the
# initramfs — no nvidia arguments on the kernel cmdline, and the module loads
# after root is mounted — so modprobe.d alone is enough. No dracut regeneration,
# but it does need a reboot to take effect.
setup-nvidia-powermgmt() {
  if ! is-fedora; then
    return
  fi
  if ! rpm -q akmod-nvidia &> /dev/null; then
    return
  fi

  # The modprobe option lives in etc/modprobe/juliet-nvidia-pm.conf.
  substep "Enabling nvidia Runtime D3 so the dGPU powers down when idle..."
  install-system-file "$JULIET_DIR/etc/modprobe/juliet-nvidia-pm.conf" \
    /etc/modprobe.d/juliet-nvidia-pm.conf
  case $? in
    0) notice "nvidia Runtime D3 change takes effect on the next reboot." ;;
    1) unchanged "already enabled" ;;
  esac
}

# How long crash evidence is worth keeping. Long enough to debug something that
# happened "the other day", short enough that a crash loop can't quietly hoard
# disk between bootstrap runs.
CRASH_RETENTION_DAYS=7

# Age-based purge of accumulated crash data. setup-coredump-limits already caps
# systemd-coredump's *size*, but nothing bounded abrt's spool: the drkonqi loop
# left 45 stale reports there, one with a repeat count of 46515. Expressed as a
# retention window rather than a one-shot wipe so it stays idempotent and keeps
# converging on every run.
setup-crash-purge() {
  if ! is-fedora; then
    return
  fi

  # abrt problem directories are named ccpp-<date>-... and owned by root; -mtime
  # is what decides, not the name, so a clock skew can't delete recent evidence.
  if [[ -d /var/spool/abrt ]]; then
    local stale
    stale=$(sudo find /var/spool/abrt -mindepth 1 -maxdepth 1 -type d \
      -mtime +"$CRASH_RETENTION_DAYS" 2> /dev/null | wc -l)
    if [[ "$stale" -gt 0 ]]; then
      substep "Purging $stale abrt report(s) older than ${CRASH_RETENTION_DAYS}d..."
      sudo find /var/spool/abrt -mindepth 1 -maxdepth 1 -type d \
        -mtime +"$CRASH_RETENTION_DAYS" -exec rm -rf {} + \
        || bootstrap_error "Failed to purge the stale abrt spool" \
          "Inspect it manually: sudo du -sh /var/spool/abrt/*"
    fi
  fi

  # coredumpctl has no age-based vacuum of its own, so drive it off the files.
  if [[ -d /var/lib/systemd/coredump ]]; then
    local cores
    cores=$(find /var/lib/systemd/coredump -type f \
      -mtime +"$CRASH_RETENTION_DAYS" 2> /dev/null | wc -l)
    if [[ "$cores" -gt 0 ]]; then
      substep "Purging $cores core dump(s) older than ${CRASH_RETENTION_DAYS}d..."
      sudo find /var/lib/systemd/coredump -type f \
        -mtime +"$CRASH_RETENTION_DAYS" -delete \
        || bootstrap_error "Failed to purge old core dumps" \
          "Inspect them manually: coredumpctl list"
    fi
  fi
}

setup-sddm-applicable() { is-fedora && command -v sddm &> /dev/null; }

setup-deplasma-applicable() { is-fedora; }

setup-undms-applicable() { is-fedora; }

setup-coredump-limits-applicable() { is-fedora; }

setup-crash-purge-applicable() { is-fedora; }

setup-nvidia-secureboot-applicable() { is-fedora && rpm -q akmod-nvidia &> /dev/null; }

setup-nvidia-powermgmt-applicable() { is-fedora && rpm -q akmod-nvidia &> /dev/null; }

setup-keyd-applicable() { is-fedora && command -v keyd &> /dev/null; }

setup-fingerprint-applicable() { is-fedora && has-goodix-533c; }
