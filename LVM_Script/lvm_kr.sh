#!/bin/bash

echo -e "\n"
echo "한글인터페이스 LVM디스크 마운트스크립트"

fdisk -l
sleep 5

echo -e "\n"
echo "#############################################################"
echo "LVM파티션 생성할 볼륨 이름을 입력해주세요(ex. /dev/nvme2n1, /dev/xvda): "
read diskname

(echo n; echo p; echo 1; echo; echo; echo t; echo 8e; echo p; echo w;) | fdisk "$diskname"
sleep 3

echo -e "\n"
echo "#############################################################"
echo "해당 서버에 설정된 LVM 파티션 입니다."
fdisk -l | grep LVM
sleep 3

echo -e "\n"
echo "#############################################################"
echo "pv 생성할 파티션을 입력해 주세요(ex. /dev/nvme1n1p1, /dev/xvda1): "
read Pname
pvcreate "$Pname"
pvscan

echo -e "\n"
echo "#############################################################"
echo "생성할 VG명을 입력해 주세요(ex. DataVG, BackupVG): "
read vgname

vgcreate "$vgname" "$Pname"
vgdisplay

echo -e "\n"
echo "#############################################################"
echo "원하는 PE Size 및 사용률을 입력해주세요(ex. 25599 , 100%FREE): "
read pesize

echo -e "\n"
echo "#############################################################"
echo "생성할 lv 이름을 입력해 주세요(ex. data, backup)"
read lvname

lvcreate -l "$pesize" -n "$lvname" "$vgname"
lvscan

echo -e "\n"
echo "#############################################################"
echo "포맷 할 파일시스템 형식을 입력해 주세요(ex. ext4 , xfs): "
read fsys

echo -e "\n"
echo "#############################################################"
echo "lv가 생성된 경로를 입력해주세요 (ex. /dev/BackupVG/backup, /dev/DataVG/data)"
read lvpath

mkfs -t "$fsys" "$lvpath"

echo -e "\n"
echo "#############################################################"
echo "마운트 경로를 입력해 주세요 (ex. /data, /backup)"
read mdir

if [ -e "$mdir" ]; then
        echo "$mdir WANRNIG: already exist"
else
        mkdir -p "$mdir"
        echo "$mdir newly created"
fi


echo -ne "$lvpath"'\t'"$mdir"'\t'"$fsys"'\t'defaults'\t'0'\t'0 >> /etc/fstab

mount -a
df -Th
