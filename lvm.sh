#!/bin/bash

echo "Enter the volume name(ex. /dev/nvme2n1, /dev/xvda): "
read name

(ex. echo n; echo p; echo 1; echo; echo; echo t; echo 8e; echo w; echo p;) | fdisk "$name"
sleep 3

echo "It's your LVM partition"
fdisk -l | grep LVM
sleep 3
echo "Enter the partition name(ex. /dev/nvme1n1p1, /dev/xvda1): "
read Pname
pvcreate "$Pname"
pvscan

echo "Enter the VG name(ex. DataVG, BackupVG): "
read vgname

echo "Enter the partition name(ex. /dev/nvme1n1p1, /dev/xvda1): "
read pvname

vgcreate "$vgname" "$pvname"
vgdisplay

echo "Enter PE Size(ex. 25599 , 100%FREE): "
read pesize

echo "Enter lv name(ex. data, backup)"
read lvname

lvcreate -l "$pesize" -n "$lvname" "$vgname"
lvscan

echo "Enter File System(ex. ext4 , xfs): "
read fsys

echo "Enter lv path (ex. /dev/BackupVG/backup, /dev/DataVG/data)"
read lvpath

mkfs -t "$fsys" "$lvpath"

echo -ne "$lvpath"'\t'"$mdir"'\t'"$fsys"'\t'defaults'\t'0'\t'0 >> /etc/fstab

df -Th
