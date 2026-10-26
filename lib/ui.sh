print_header() {
    printf '\n'
    printf 'hyprkit 0.1%38s\n' 'made by yavkhr'
    printf '\n'
    printf '  Система   : %s' "$DISTRO_NAME"
    [ -n "$PKG_MGR" ] && printf ' (%s)' "$PKG_MGR"
    printf '\n'
    if [ -n "$HYPR_VER" ]; then
        printf '  Hyprland  : %s\n' "$HYPR_VER"
    else
        printf '  Hyprland  : не найден\n'
    fi
    if [ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]; then
        printf '  Сессия    : запущена\n'
    else
        printf '  Сессия    : не запущена\n'
    fi
    printf '\n'
}

print_menu() {
    local i=1 dir name state
    for dir in "${COMPONENTS[@]}"; do
        name="$(comp_var "$dir" NAME)"
        if comp_check "$dir"; then
            state='установлено'
        else
            state='не установлено'
        fi
        printf '  %d) %s — %s\n' "$i" "$name" "$state"
        i=$((i + 1))
    done
    printf '\n'
}

print_prompt() {
    printf '  Номера через запятую, a — всё, q — выход\n'
    printf '  > '
}

print_done() {
    printf '  %s: установлено\n' "$1"
}

print_fail() {
    printf '  %s: ошибка, см. %s\n' "$1" "${LOG:-/dev/null}"
}
