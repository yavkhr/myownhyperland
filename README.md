# fedora-hyperland-by-yavkhr

моя личная конфигурация hyprland на fedora.

## описание

здесь лежат мои конфиги и скрипты для hyprland, собранные под fedora linux.
всё заточено под быстрый и минималистичный рабочий процесс, без лишнего.

## что внутри

* готовые бинды на частые действия
* своя панель waybar
* скрипты для запуска приложений и переключения рабочих столов
* локскрин hyprlock со своим оформлением
* меню hyprwat для wi-fi, языка и питания
* обои, шрифты и хоткеи в одном месте

## установка

```bash
git clone https://github.com/yavkhr/fedora-hyperland-by-yavkhr.git
cd fedora-hyperland-by-yavkhr
./hyprkit
```

запускаешь файл `./hyprkit` дальше он сам смотрит,что уже стоит,показывает
меню и ставит только выбранное. зависимости вроде waybar и hyprlock проверит
сам и предложит доставить.

если меню не нужно,можно так:

```bash
./hyprkit --install waybar lock binds
```

компоненты: `waybar`, `lock`, `binds`, `wallpaper`, `menu`, `fonts`.
список с id `./hyprkit --list`.

## использование

после установки перезайди в сессию или запусти hyprland из tty.

хоткеи: `super+return`kitty, `super+space` — fuzzel, `super+q` закрыть
окно, `super+shift+s` скриншот, `super+m` блокировка, `super+f12` выход.

проверить, что всё на месте:

```bash
hyprctl version
```

старые конфиги не пропадают: при установке они уезжают в
`~/.hyprkit-backup-<дата>`. лог пакетных менеджеров `~/.hyprkit.log`.

## заметки

бинды в lua. hyprland ниже 0.56 его не понимает,там ставится обычный
`hyprland.conf` с теми же хоткеями.

`hyprwat` собран под linux x86_64. на другой архитектуре его надо собирать
из исходников.

шрифт jetbrainsmono nerd font качается с github,около 130 мб.без интернета
встанет только symbols.
