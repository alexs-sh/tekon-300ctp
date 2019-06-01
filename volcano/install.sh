#!/bin/bash
ARCHNAME=volcano.tar.gz
TEKONDIR=/home/volcano/tekon
SERVICES=(
tekon.target 
tekon_usb.service
tekon_master.service
tekon_ramfs.service 
)


fail()
{
  echo "Installation failed"
  exit 1
}

echo "================================================================================"
echo " Checking"
echo "================================================================================"
if [ ! -f ${ARCHNAME} ]; then
  echo "File ${ARCHNAME} is missing"
  fail
fi

if [ "$(id -u)" != "0" ]; then
  echo "This script must be run as root"
  fail
fi
echo "OK"
echo ""

echo "================================================================================"
echo " Stopping Tekon services"
echo "================================================================================"
for srv in ${SERVICES[*]}; do
  systemctl stop "${srv}" && echo "${srv} stopped"
done
echo ""

echo "================================================================================"
echo " Extracting files"
echo "================================================================================"
(tar xzf ${ARCHNAME} -C / && echo "OK") || fail
echo ""

echo "================================================================================"
echo " Configuring Tekon"
echo "================================================================================"
if [ -f "${TEKONDIR}/config" ]; then
  echo "Tekon config already exists"
else
  (cp ${TEKONDIR}/defconfig ${TEKONDIR}/config && echo "OK") || fail
fi
echo ""

echo "================================================================================"
echo " Configuring locales"
echo "================================================================================"
sed -i 's/# ru_RU.UTF-8/ru_RU.UTF-8/' /etc/locale.gen
sed -i 's/# en_US.UTF-8/en_US.UTF-8/' /etc/locale.gen
locale-gen

grep -q "export LANG=en_US.UTF-8"  /etc/profile 
result=$?
if [ $result -ne 0 ]; then
  echo "export LANG=en_US.UTF-8" >> /etc/profile
fi
echo ""

echo "================================================================================"
echo " Configuring TZ"
echo "================================================================================"
echo "Asia/Yekaterinburg" > /etc/timezone
rm /etc/localtime
ln -s /usr/share/zoneinfo/Asia/Yekaterinburg /etc/localtime
dpkg-reconfigure -f noninteractive tzdata || fail
echo ""

echo "================================================================================"
echo " Configuring systemd"
echo "================================================================================"
systemctl daemon-reload 
(systemctl enable tekon.target && echo "OK") || fail
echo ""

echo "================================================================================"
echo " Starting Tekon services"
echo "================================================================================"
systemctl start tekon.target 
sleep 3
systemctl status tekon.target 
systemctl status tekon_ramfs
systemctl status tekon_usb
systemctl status tekon_master
echo ""
