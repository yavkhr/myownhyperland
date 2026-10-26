BACKUP_DIR=""

ask_yes() {
    local prompt="$1" ans
    read -r -p "$prompt" ans
    case "$ans" in
        n|N|no|нет|н) return 1 ;;
        *) return 0 ;;
    esac
}

backup_path() {
    local p="$1" dst
    [ -e "$p" ] || [ -L "$p" ] || return 0
    [ -L "$p" ] && return 0
    [ -n "$BACKUP_DIR" ] || return 0
    if [ "${p#$HOME/}" != "$p" ]; then
        dst="$BACKUP_DIR/${p#$HOME/}"
    else
        dst="$BACKUP_DIR/${p#/}"
    fi
    mkdir -p "$(dirname "$dst")"
    mv "$p" "$dst"
}

dest_for() {
    case "$1" in
        config) printf '%s' "$HOME/.config" ;;
        bin) printf '%s' "$HOME/.local/bin" ;;
        assets) printf '%s' "$HOME/Pictures" ;;
        fonts) printf '%s' "$HOME/.local/share/fonts" ;;
    esac
}

lua_skip() {
    local rel="$1"
    case "$rel" in
        hypr/hyprland.lua) [ "$LUA_OK" = "1" ] && return 1 || return 0 ;;
        hypr/hyprland.conf) [ "$LUA_OK" = "1" ] && return 0 || return 1 ;;
    esac
    return 1
}

place_entry() {
    local src="$1" target="$2" rel="$3"
    mkdir -p "$(dirname "$target")"
    backup_path "$target"
    case "$rel" in
        *.tmpl)
            sed -e "s|__HOME__|$HOME|g" -e "s|__USER__|$USER|g" "$src" > "${target%.tmpl}"
            ;;
        *)
            ln -sfn "$src" "$target"
            chmod +x "$target" 2>/dev/null || true
            ;;
    esac
}

install_files() {
    local dir kind src base rel entry
    dir="$(cd "$1" && pwd)"
    for kind in config bin assets fonts; do
        src="$dir/files/$kind"
        [ -d "$src" ] || continue
        base="$(dest_for "$kind")"
        mkdir -p "$base"

        if [ "$kind" = "config" ]; then
            while IFS= read -r -d '' rel; do
                rel="${rel#./}"
                lua_skip "$rel" && continue
                place_entry "$src/$rel" "$base/$rel" "$rel"
            done < <(cd "$src" && find . -type f -print0)
        else
            for entry in "$src"/*; do
                [ -e "$entry" ] || continue
                rel="$(basename "$entry")"
                place_entry "$entry" "$base/$rel" "$rel"
            done
        fi
    done
}
