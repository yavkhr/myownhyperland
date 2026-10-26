DISTRO_NAME="unknown Linux"
PKG_MGR=""
PKG_FAMILY=""
HYPR_VER=""
LUA_OK=0
SUDO=""

detect_system() {
    if [ -r /etc/os-release ]; then
        DISTRO_NAME="$(
            . /etc/os-release 2>/dev/null
            printf '%s' "${PRETTY_NAME:-${NAME:-unknown Linux}}"
        )"
    fi

    if command -v dnf >/dev/null 2>&1; then
        PKG_MGR=dnf
    elif command -v pacman >/dev/null 2>&1; then
        PKG_MGR=pacman
    elif command -v apt-get >/dev/null 2>&1; then
        PKG_MGR=apt
    elif command -v zypper >/dev/null 2>&1; then
        PKG_MGR=zypper
    fi

    case "$PKG_MGR" in
        dnf) PKG_FAMILY=fedora ;;
        pacman) PKG_FAMILY=arch ;;
        apt) PKG_FAMILY=debian ;;
        zypper) PKG_FAMILY=suse ;;
        *) PKG_FAMILY=unknown ;;
    esac

    HYPR_VER="$(
        hyprctl version 2>/dev/null |
        awk 'NR==1 { for (i = 1; i <= NF; i++) if ($i ~ /^[0-9]+\.[0-9]+/) { print $i; exit } }'
    )"
    if [ -z "$HYPR_VER" ]; then
        HYPR_VER="$(
            Hyprland --version 2>/dev/null |
            awk '{ for (i = 1; i <= NF; i++) if ($i ~ /^[0-9]+\.[0-9]+/) { print $i; exit } }'
        )"
    fi

    if [ -n "$HYPR_VER" ]; then
        local major minor rest
        major="${HYPR_VER%%.*}"
        rest="${HYPR_VER#*.}"
        minor="${rest%%.*}"
        if [ "$major" -gt 0 ] 2>/dev/null || { [ "$major" -eq 0 ] 2>/dev/null && [ "$minor" -ge 56 ] 2>/dev/null; }; then
            LUA_OK=1
        fi
    fi

    if [ "$(id -u)" -eq 0 ]; then
        SUDO=""
    elif command -v sudo >/dev/null 2>&1; then
        SUDO=sudo
    fi
}
