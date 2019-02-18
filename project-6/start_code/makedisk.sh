# dd if=/dev/zero of=disk bs=512 count=4M
make all
dd if=image of=disk conv=notrunc
cp disk ../QEMULoongson/disk
