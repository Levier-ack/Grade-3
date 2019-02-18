# dd if=/dev/zero of=disk bs=64 count=1M
make all
dd if=image of=disk conv=notrunc
cp disk ../QEMULoongson/disk
