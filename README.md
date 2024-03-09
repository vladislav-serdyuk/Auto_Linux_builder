# Auto Linux builder
Автоматическая сборка своего дистрибутива

## Главное

Перед шаманством установите make:
> sudo apt install make

Далее, после скачивания вот этого чуда с github, перейдите в папку распоковки.
После чего введите:
> sudo make build

или
> sudo make -jN build

Где вместо N можно поставить 1, 2, 3, ... подробнее в мануалах GNU make.
Для проверки дистрибутива введите:
> make test

## Допольнительно

Вы можите ввести 'sudo make libinstall' для установки всех доп. зависемостей,
скачать исходники ядра 'make ldlinux', и busybox 'make ldbusybox',
отдельно собрать ядро 'make buildlinux', busybox 'make buildbusybox', и initrd 'make buildinitrd'.

Используйте это для удаления всех созданных файлов:
> make clean

'make build' выполняет сначала libinstall после чего buildall,
поэтому в следущий раз используйте имено 'make buildall'

Фаил files/init является скриптом иницализации ram диска.

На этом пока всё :)

## Использованое ПО
- Linux © Linus Torvalds GNU GPL
- Busybox © 1999-2008 Erik Andersen
- dpkg © The Debian GNU GPL
