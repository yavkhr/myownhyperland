#!/usr/bin/env bash
# =============================================================================
#  Мой конфиг Fedora + Hyprland: waybar, бинды, hyprlock
#
#  ./install.sh          # поставить
#  ./install.sh -y       # без вопросов
#  ./install.sh --no-fonts
#
#  Ничего не требует, кроме пользовательских прав (sudo не нужен).
#  Перезаписываемые файлы уезжают в ~/.hypr-config-backup-<дата>
# =============================================================================

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="$REPO_DIR/source"
HOME_DIR="$HOME"
STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP_DIR="$HOME_DIR/.hypr-config-backup-$STAMP"

SKIP_FONTS=0

bold() { printf '\033[1m%s\033[0m\n' "$*"; }
info() { printf '\033[36m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[33m[!]\033[0m %s\n' "$*"; }
die()  { printf '\033[31m[x]\033[0m %s\n' "$*" >&2; exit 1; }

for arg in "$@"; do
    case "$arg" in
        -y|--yes)     ;;
        --no-fonts)   SKIP_FONTS=1 ;;
        -h|--help)    sed -n '2,15p' "$0"; exit 0 ;;
        *)            die "Неизвестный аргумент: $arg" ;;
    esac
done

[ -d "$SRC" ] || die "Не найдена папка source рядом со скриптом"

backup_path() {
    local p="$1"
    [ -e "$p" ] || [ -L "$p" ] || return 0
    [ -L "$p" ] && return 0
    local dst="$BACKUP_DIR/${p#/}"
    mkdir -p "$(dirname "$dst")"
    mv "$p" "$dst"
}

link_file() {
    local src="$1" dst="$2"
    mkdir -p "$(dirname "$dst")"
    backup_path "$dst"
    ln -sfn "$src" "$dst"
}

render_tmpl() {
    local src="$1" dst="$2"
    mkdir -p "$(dirname "$dst")"
    backup_path "$dst"
    sed -e "s|__HOME__|$HOME_DIR|g" -e "s|__USER__|$USER|g" "$src" > "$dst"
}

bold "Конфиг Hyprland + Waybar"
echo "  HOME : $HOME_DIR"
echo

# ------------------------------------------------------------ 1. конфиги
info "Симлинкую конфиги в ~/.config"
for group in "$SRC"/config/*/; do
    name="$(basename "$group")"
    while IFS= read -r -d '' rel; do
        rel="${rel#./}"
        case "$(basename "$rel")" in
            *.tmpl) ;;
            *) link_file "${group%/}/$rel" "$HOME_DIR/.config/$name/$rel" ;;
        esac
    done < <(cd "$group" && find . -type f -print0)
done

info "Генерирую hyprlock.conf и hyprpaper.conf"
for tmpl in "$SRC"/config/hypr/*.tmpl; do
    [ -e "$tmpl" ] || continue
    render_tmpl "$tmpl" "$HOME_DIR/.config/hypr/$(basename "$tmpl" .tmpl)"
done

# ------------------------------------------------------------ 2. скрипты
info "Ставлю скрипты в ~/.local/bin"
mkdir -p "$HOME_DIR/.local/bin"
while IFS= read -r -d '' file; do
    dst="$HOME_DIR/.local/bin/$(basename "$file")"
    link_file "$file" "$dst"
    chmod +x "$dst" 2>/dev/null || true
done < <(find "$SRC/bin" -maxdepth 1 -type f -print0)

# ------------------------------------------------------------- 3. ассеты
info "Ссылаю аватар и обои в ~/Pictures"
mkdir -p "$HOME_DIR/Pictures"
for asset in "$SRC"/assets/*; do
    [ -e "$asset" ] || continue
    link_file "$asset" "$HOME_DIR/Pictures/$(basename "$asset")"
done

# ------------------------------------------------------------ 4. шрифты
if [ "$SKIP_FONTS" = "0" ]; then
    mkdir -p "$HOME_DIR/.local/share/fonts"

    if [ -d "$SRC/fonts/NerdFontsSymbolsOnly" ]; then
        info "Nerd Fonts Symbols"
        link_file "$SRC/fonts/NerdFontsSymbolsOnly" \
                  "$HOME_DIR/.local/share/fonts/NerdFontsSymbolsOnly"
    fi

    if ! fc-list 2>/dev/null | grep -i "JetBrainsMono Nerd" >/dev/null; then
        info "Качаю JetBrainsMono Nerd Font (~130 МБ)"
        TMPFONT="$(mktemp -d)"
        if curl -fsSL -o "$TMPFONT/jb.zip" \
            "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"; then
            mkdir -p "$HOME_DIR/.local/share/fonts/JetBrainsMonoNF"
            if command -v bsdtar >/dev/null 2>&1; then
                bsdtar -xf "$TMPFONT/jb.zip" -C "$HOME_DIR/.local/share/fonts/JetBrainsMonoNF"
            elif command -v unzip >/dev/null 2>&1; then
                unzip -oq "$TMPFONT/jb.zip" -d "$HOME_DIR/.local/share/fonts/JetBrainsMonoNF"
            fi
        else
            warn "Не скачалось. Поставь вручную: sudo dnf install jetbrains-mono-fonts-all"
        fi
        rm -rf "$TMPFONT"
    fi
    fc-cache -f >/dev/null 2>&1 || true
else
    info "Шрифты пропущены (--no-fonts)"
fi

# --------------------------------------------------------------- 5. итог
echo
bold "Готово."
echo "  hyprland.lua  : ~/.config/hypr/hyprland.lua   (активный конфиг, бинды)"
echo "  hyprlock      : ~/.config/hypr/hyprlock.conf  (сгенерирован)"
echo "  waybar        : ~/.config/waybar/"
echo "  скрипты       : ~/.local/bin/"
echo "  бэкап старого : $BACKUP_DIR"
echo
echo "Дальше: hyprctl reload && pkill waybar; waybar &"
echo "Проверка биндов: hyprctl binds | head"
