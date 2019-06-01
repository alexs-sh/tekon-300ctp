# TEKON 300 ЦТП
Адаптация [tekon-utils](https://github.com/alexs-sh/tekon-utils) и [tekon-scripts](https://github.com/alexs-sh/tekon-scripts) для проекта 300 ЦТП.
Позволяет получить бинарные файлы для платформ, применяемых в проекте. А так же инструменты для быстрой развертки и настройки на устройствах [Volcano](https://manometr-npc.ru/catalog/io-controllers/riom-scomm)

# Применение

## Сборка и передача на Volcano

``` Console
git clone --recursive https://github.com/alexs-sh/tekon-300ctp.git 
cd  tekon-300ctp
./volcano/build.sh
scp -P 2203 install.sh volcano.tar.gz root@10.0.0.5:/tmp
```

В примере выполнено:

  - получение проекта
  
  - кросс-компиляция для архитектуры ARMv7
  
  - сборка архива для Volcano (volcano.tar.gz) и генерация установочного сркипта (install.sh)
  
  - передача архива и скрипта на утсройство с адресом 10.0.0.5 в директорию /tmp

## Установка на Volcano

``` Console
ssh -p 2203 root@10.0.0.5
cd /tmp
./install.sh 
```

В примере выполнен вход по ssh и запуск установочного скрипта, созданного и переданного на предыдущем шаге.


## Работа с сервисами Тэкон

Конфигурирование опроса счетчиков выполняется при помощи файла **/home/volcano/tekon/config**

Для Тэкона доступно 3 сервиса (tekon_*.service), объединенных в одну группу
(tekon.target)

  - tekon_ramfs.service - обеспечивает подключение ramfs для хранения считанных
данных в оперативной памяти устройства

  - tekon_master.service - обеспечивает работу со счетчиками (чтение параметров,
чтение архивов, синхронизацию времени)

  - tekon_usb.service - обеспечивает запись архивов на USB.

Управление сервисами выполняется при помощи systemd. 

**systemctl enable tekon.target** - разрешить сервисы Тэкон (разрешает автозапуск)

**systemctl start tekon.target** - запустить сервисы Тэкон (запускает, но не разрешает в автозапуск)

**systemctl stop tekon.target** - остановить сервисы Тэкон (останавливает, но не запрещает автозапуск)

**systemctl disable tekon.target** - запретить сервисы Тэкон (запрещает автозапуск)

**systemctl status tekon.target** - проверить состояние

По каждому из сервисов можно получить более детальную информация. 

**systemctl status tekon_usb.service** - получить статус службы записи на USB

**systemctl status $(systemctl list-unit-files  | grep tekon_.*)** - вывести информацию по всем сервисам Тэкон

