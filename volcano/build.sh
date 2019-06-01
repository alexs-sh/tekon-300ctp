#!/bin/bash

# Автосборка всех компонентов для Volcano
# Запускается из корня проекта

OUTDIR=/tmp/tekon-300-ctp-build$$
BUILDDIR=armhf$$

rm -rf ${OUTDIR}
mkdir -p ${OUTDIR}
mkdir -p ${OUTDIR}/usr/bin
mkdir -p ${OUTDIR}/etc/systemd/system
mkdir -p ${OUTDIR}/home/volcano/tekon

echo "================================================================================"
echo " Tekon Master"
echo "================================================================================"
cd tekon-scripts/master || exit 1
./build.sh && cp  ./tekon_master ${OUTDIR}/usr/bin
cp defconfig ${OUTDIR}/home/volcano/tekon
cd - > /dev/null || exit 1
echo ""

echo "================================================================================"
echo " Tekon USB"
echo "================================================================================"
cd tekon-scripts/usb || exit 1
./build.sh && cp  ./tekon_usb ${OUTDIR}/usr/bin
cd - > /dev/null || exit 1
echo ""

echo "================================================================================"
echo " Tekon Utils"
echo "================================================================================"
cd tekon-utils || exit 1
mkdir -p ${BUILDDIR}
cd ${BUILDDIR} || exit 1
cmake -G "Ninja" -DCMAKE_C_COMPILER=arm-linux-gnueabihf-gcc -DCMAKE_FIND_ROOT_PATH=/usr/arm-linux-gnueabihf -DCMAKE_BUILD_TYPE=Release -DCMAKE_C_FLAGS_RELEASE="-O3 -DNDEBUG  -Wall -Wextra -Wno-unused-parameter -std=c99" -DCMAKE_INSTALL_PREFIX=${OUTDIR}/usr ..
ninja
ninja install
cd ../.. > /dev/null || exit 1
echo ""

echo "================================================================================"
echo " Systemd Units"
echo "================================================================================"
cp volcano/tekon* ${OUTDIR}/etc/systemd/system
ls -l ${OUTDIR}/etc/systemd/system
echo ""

echo "================================================================================"
echo " Pack"
echo "================================================================================"
cd ${OUTDIR} || exit 1
tar zcf volcano.tar.gz etc usr home || exit 1
md5sum volcano.tar.gz | tee volcano.md5
cd - > /dev/null || exit 1
cp ${OUTDIR}/volcano.tar.gz .

cp volcano/install.sh .
md5sum install.sh | tee install.md5
echo ""

