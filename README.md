# Мой конфиг Hyprland (Fedora 44)

Только то, что делает рабочий стол: **бинды Hyprland**, **waybar**, **hyprlock**
(мой кастомный локскрин) и меню **hyprwat**, которое вызывает waybar.

```
git clone https://github.com/yavkhr/fedora-hyperland-by-yavkhr.git
cd fedora-hyperland-by-yavkhr
./install.sh
```

Полный бэкап системы (пакеты, `/etc`, шрифты, всё остальное) лежит в приватном
репозитории `myownfedora44`.

## Что внутри

```
source/
├── config/
│   ├── hypr/
│   │   ├── hyprland.lua          # активный конфиг: бинды, раскладка us,ru, медиа-клавиши
│   │   ├── hyprlock.conf.tmpl    # локскрин: аватар, blur, поле ввода пароля
│   │   └── hyprpaper.conf.tmpl   # обои
│   ├── waybar/                   # config.jsonc + style.css
│   └── hyprwat/                  # тема меню + menus/powermenu.yaml
├── bin/                          # waybar-*, lock-hyprland, take-screenshot, hyprwat
├── assets/                       # my_ava.jpg, bg-blue.png
└── fonts/NerdFontsSymbolsOnly/
```

`hyprland.conf` в репозиторий не входит: Hyprland читает `hyprland.lua`
(все 61 бинд в рантайме зарегистрированы Lua).

## `install.sh`

- симлинкует `source/config/*` в `~/.config/`
- генерирует `hyprlock.conf` / `hyprpaper.conf` с реальным `$HOME`
- ставит скрипты и `hyprwat` в `~/.local/bin`
- линкует аватар/обои в `~/Pictures`
- ставит шрифты (Nerd Fonts Symbols + JetBrainsMono Nerd Font)

Флаги: `-y`, `--no-fonts`. `sudo` не нужен, старые файлы бэкапятся в
`~/.hypr-config-backup-<дата>`.

## После установки

```bash
hyprctl reload
pkill waybar; waybar &
```

Бинды: `Super+Return` — kitty, `Super+Space` — fuzzel, `Super+Q` — killactive,
`Super+E` — exit, `Super+S` — скриншот, `Super+M` — блокировка.

## Зависимости

`hyprland`, `waybar`, `hyprlock`, `hyprpaper`, `kitty`, `fuzzel`, `grim`, `slurp`,
`wl-clipboard`, `nmcli` (NetworkManager), `wpctl`/`pavucontrol` (PipeWire).

## hyprwat

Wayland-меню (Wi-Fi, выбор языка, power-меню), бинарь `0.11.5` лежит в
`source/bin/hyprwat`. Исходники: <https://github.com/zackb/hyprwat>.

`menus/powermenu.yaml` пока ни к чему не привязан — можно повесить так:

```
bind = SUPER, X, exec, hyprwat --custom ~/.config/hyprwat/menus/powermenu.yaml
```
