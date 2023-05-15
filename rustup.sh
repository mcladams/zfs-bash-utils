# shellcheck shell=sh
# /etc/profile.d/app-bin-path.sh from upuntu snapd used as template

# Expand $PATH to include the directory where cargp bomaroes go.
cargo_bin_path="/opt/rust/bin"
if [ -n "${PATH##*${cargo_bin_path}}" ] && [ -n "${PATH##*${cargo_bin_path}:*}" ]; then
    export PATH="$PATH:${cargo_bin_path}"
fi

export RUSTUP_HOME="/opt/rust"
export CARGO_HOME="/opt/rust"

# rustup now supports generating completion scripts for Bash, Fish, Zsh
# See rustup help completions for full details using one of the following:
#
# Bash
# $ rustup completions bash > ~/.local/share/bash-completion/completions/rustup
#
# Fish
# $ mkdir -p ~/.config/fish/completions
# $ rustup completions fish > ~/.config/fish/completions/rustup.fish
#
# Zsh
# $ rustup completions zsh > ~/.zfunc/_rustup

# script for XDG dirs below from snapd script in case future relevance
#
# Ensure base distro defaults xdg path are set if nothing filed up some
# defaults yet.
#if [ -z "$XDG_DATA_DIRS" ]; then
#    export XDG_DATA_DIRS="/usr/local/share:/usr/share"
#fi
#
# Desktop files (used by desktop environments within both X11 and Wayland) are
# looked for in XDG_DATA_DIRS; make sure it includes the relevant directory for
# snappy applications' desktop files.
#snap_xdg_path="/var/lib/snapd/desktop"
#if [ -n "${XDG_DATA_DIRS##*${snap_xdg_path}}" ] && [ -n "${XDG_DATA_DIRS##*${snap_xdg_path}:*}" ]; then
#    export XDG_DATA_DIRS="${XDG_DATA_DIRS}:${snap_xdg_path}"
#fi
