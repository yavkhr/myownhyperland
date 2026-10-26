#!/usr/bin/env bash
set -uo pipefail

if fc-list 2>/dev/null | grep -qi "JetBrainsMono Nerd"; then
    exit 0
fi

target="$HOME/.local/share/fonts/JetBrainsMonoNF"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

curl -fsSL -o "$tmp/jb.zip" \
    "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip" || exit 1

mkdir -p "$target"
if command -v bsdtar >/dev/null 2>&1; then
    bsdtar -xf "$tmp/jb.zip" -C "$target"
elif command -v unzip >/dev/null 2>&1; then
    unzip -oq "$tmp/jb.zip" -d "$target"
else
    exit 1
fi

fc-cache -f >/dev/null 2>&1 || true
