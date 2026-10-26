# hyprkit — мой конфиг Hyprland

Терминальный установщик: проверяет систему и Hyprland, показывает меню
компонентов и ставит только то, что выбрал.

```
git clone https://github.com/yavkhr/fedora-hyperland-by-yavkhr.git
cd fedora-hyperland-by-yavkhr
./hyprkit
```

**made by yavkhr**

## Подходит не только Fedora

Пакетный менеджер определяется сам: `dnf`, `pacman`, `apt`, `zypper`.
На неизвестной системе скрипт не падает, а показывает, что поставить вручную.

Требования: Linux + Hyprland. Для биндов в формате Lua нужен Hyprland 0.56+,
на более старых автоматически ставится вариант `hyprland.conf`.

## Меню

```
hyprkit 0.1                        made by yavkhr

  Система   : Fedora Linux 44 (dnf)
  Hyprland  : 0.56.2
  Сессия    : запущена

  1) Waybar — установлено
  2) Lock screen — не установлено
  3) Бинды — установлено
  4) Обои — не установлено
  5) Меню hyprwat — не установлено
  6) Шрифты — не установлено

  Номера через запятую, a — всё, q — выход
  >
```

Состояние определяется по факту: конфиг на месте, бинарь найден, шрифт
виден в `fc-list`. После установки пункт помечается как установленный.

## Команды

```
./hyprkit                 интерактивное меню
./hyprkit --list          список компонентов и ID
./hyprkit --install waybar lock
```

## Компоненты

| ID | Что ставит | Куда |
|---|---|---|
| `waybar` | панель: раскладка, VPN/Wi-Fi, звук, температуры, память, питание + скрипты | `~/.config/waybar`, `~/.local/bin` |
| `lock` | мой hyprlock: аватар, blur, поле ввода пароля | `~/.config/hypr/hyprlock.conf`, `~/Pictures` |
| `binds` | бинды и настройки Hyprland (`hyprland.lua` или `hyprland.conf`) + лончеры | `~/.config/hypr`, `~/.local/bin` |
| `wallpaper` | обои для hyprpaper | `~/.config/hypr/hyprpaper.conf`, `~/Pictures` |
| `menu` | hyprwat: Wi-Fi, выбор языка, power-меню | `~/.config/hyprwat`, `~/.local/bin` |
| `fonts` | Nerd Fonts Symbols + JetBrainsMono Nerd Font | `~/.local/share/fonts` |

Компонент сам проверяет зависимости (`waybar`, `hyprlock`, `hyprpaper`,
`hyprland`) и предлагает поставить недостающие через пакетный менеджер.

## Что происходит с файлами

- Конфиги симлинкуются в `~/.config` — правки сразу попадают в клонированный репозиторий.
- `hyprlock.conf` и `hyprpaper.conf` генерируются из шаблонов с реальным `$HOME`.
- Всё, что будет перезаписано, уезжает в `~/.hyprkit-backup-<дата>`.
- Вывод пакетных менеджеров пишется в `~/.hyprkit.log`.
- Повторный запуск безопасен.

## После установки

```bash
hyprctl reload
pkill waybar; waybar &
```

Бинды: `Super+Return` — kitty, `Super+Space` — fuzzel, `Super+Q` — killactive,
`Super+Shift+S` — скриншот, `Super+M` — блокировка, `Super+F12` — выход.

## Ограничения

- `hyprwat` — готовый бинарь только для Linux x86_64.
- JetBrainsMono Nerd Font качается с GitHub (~130 МБ), без сети поставится
  только пакет из репозитория.
- Скрипты лончеров (`viber`, `telegram`, `obsidian`) — обёртки под мои пути;
  поправь под себя в `~/.local/bin`.
- Полный бэкап системы (пакеты, `/etc`, настройки драйверов) лежит в приватном
  репозитории `myownfedora44`.
