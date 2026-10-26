COMPONENTS=()

load_components() {
    local dir line
    local entries=()
    COMPONENTS=()
    for dir in "$ROOT"/components/*/; do
        [ -f "${dir}manifest.sh" ] || continue
        entries+=("$(comp_var "${dir%/}" ORDER)|${dir%/}")
    done
    while IFS= read -r line; do
        COMPONENTS+=("${line#*|}")
    done < <(printf '%s\n' "${entries[@]}" | sort -t'|' -k1,1n)
}

comp_var() {
    local dir="$1" field="$2"
    (
        . "$dir/manifest.sh"
        eval "printf '%s' \"\${$field}\""
    )
}

comp_deps() {
    local dir="$1" fam
    fam="DEPS_${PKG_FAMILY^^}"
    (
        . "$dir/manifest.sh"
        eval "printf '%s\n' \"\${${fam}[@]}\""
    ) | while IFS= read -r p; do
        [ -n "$p" ] && printf '%s\n' "$p"
    done
}

comp_check() {
    (
        . "$1/manifest.sh"
        eval "$CHECK"
    ) >/dev/null 2>&1
}

comp_by_number() {
    local n="$1"
    [ "$n" -ge 1 ] 2>/dev/null || return 1
    [ "$n" -le "${#COMPONENTS[@]}" ] 2>/dev/null || return 1
    printf '%s' "${COMPONENTS[$((n - 1))]}"
}

comp_by_name() {
    local want="$1" dir
    for dir in "${COMPONENTS[@]}"; do
        if [ "$(comp_var "$dir" ID)" = "$want" ]; then
            printf '%s' "$dir"
            return 0
        fi
        if [ "$(comp_var "$dir" NAME | tr '[:upper:]' '[:lower:]')" = "$(printf '%s' "$want" | tr '[:upper:]' '[:lower:]')" ]; then
            printf '%s' "$dir"
            return 0
        fi
    done
    return 1
}

deps_missing() {
    local dir="$1" p
    while IFS= read -r p; do
        pkg_installed "$p" || printf '%s\n' "$p"
    done < <(comp_deps "$dir")
}

install_component() {
    local dir="$1" name missing
    name="$(comp_var "$dir" NAME)"

    missing="$(deps_missing "$dir" | tr '\n' ' ')"
    missing="${missing% }"
    if [ -n "$missing" ]; then
        printf '  Нужно поставить: %s\n' "$missing"
        if ! ask_yes "  Поставить? [Y/n] "; then
            print_fail "$name"
            return 1
        fi
        if ! pkg_install $missing; then
            print_fail "$name"
            return 1
        fi
    fi

    if ! install_files "$dir"; then
        print_fail "$name"
        return 1
    fi

    if [ -x "$dir/post.sh" ]; then
        "$dir/post.sh" >>"$LOG" 2>&1 || true
    fi

    print_done "$name"
}
