pkg_installed() {
    case "$PKG_MGR" in
        dnf|zypper) rpm -q "$1" >/dev/null 2>&1 ;;
        pacman) pacman -Qi "$1" >/dev/null 2>&1 ;;
        apt) dpkg -s "$1" >/dev/null 2>&1 ;;
        *) return 1 ;;
    esac
}

pkg_install() {
    if [ -z "$PKG_MGR" ]; then
        printf '  Пакетный менеджер не определён. Поставь вручную: %s\n' "$*"
        return 1
    fi
    [ -n "$SUDO" ] || [ "$(id -u)" -eq 0 ] || {
        printf '  Нет sudo, поставь вручную: %s\n' "$*"
        return 1
    }
    case "$PKG_MGR" in
        dnf) $SUDO dnf install -y "$@" >>"$LOG" 2>&1 ;;
        pacman) $SUDO pacman -S --noconfirm --needed "$@" >>"$LOG" 2>&1 ;;
        apt) $SUDO apt-get install -y "$@" >>"$LOG" 2>&1 ;;
        zypper) $SUDO zypper --non-interactive install "$@" >>"$LOG" 2>&1 ;;
    esac
}
