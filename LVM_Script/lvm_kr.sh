#!/bin/bash
if [ $(id -u) -ne 0 ]; then exec sudo bash "$0" "$@"; exit; fi

fdisk -l
echo -e "\033[47;31m한글인터페이스 LVM디스크 마운트스크립트\033[0m"
sleep 3

#볼륨네임을 입력하면 name 변수로 변환
echo -e "\n"
echo -e "\033[47;31mLVM파티션 생성할 볼륨 이름을 입력해주세요(ex. /dev/nvme2n1, /dev/xvda): \033[0m"
read diskname

#diskname 변수로 적용된 볼륨에 대해 LVM 파티션 적용
(echo n; echo p; echo 1; echo; echo; echo t; echo 8e; echo p; echo w;) | fdisk "$diskname"
sleep 3

#LVM을 적용할 피티션명을 입력하여 Pname 변수로
echo -e "\033[47;31m해당 서버에 설정된 LVM 파티션 입니다.\033[0m"
fdisk -l | grep LVM
sleep 3
echo -e "\033[47;31mpv 생성에 필요한 파티션명을 입력해 주세요(ex. /dev/nvme1n1p1, /dev/xvda1): \033[0m"
read Pname
pvcreate "$Pname"
pvscan

#VG에 적용할 이름을 입력 받아 vgname 변수로 변환
echo -e "\033[47;31m생성할 VG명을 입력해 주세요(ex. DataVG, BackupVG): \033[0m"
read vgname

#입력받은 VG명과 파티션 명을 변수로 적용하여 vgcreate 명령 실행 및 결과 확인
vgcreate "$vgname" "$Pname"
vgdisplay

#PE Size에 적용할 값을 입력 받아 pesize 변수로 변환
echo -e "\033[47;31m원하는 PE Size 및 사용률을 입력해주세요(ex. 25599 , 100%FREE): \033[0m"
read pesize

#lv name에 적용할 값을 입력 받아 lvname 변수로 변환
echo -e "\033[47;31m생성할 lv 이름을 입력해 주세요(ex. data, backup): \033[0m"
read lvname

#입력받은 VG명, PE Size, lv name을 변수로 적용하여 lvcreate 명령 실행 및 결과 확인
lvcreate -l "$pesize" -n "$lvname" "$vgname"
lvscan

#입력받은 파일 시스템을 fsys 변수로 적용
echo -e "\033[47;31m포맷 할 파일시스템 형식을 입력해 주세요(ex. ext4 , xfs): \033[0m"
read fsys

#lvscan에 적용된 LV경로를 출력하며, 원하는 경로를 입력하면 lvpath 변수로 적용함
echo -e "\033[47;31m생성된 LV 경로입니다.\033[0m"
lvscan
sleep 3
echo -e "\033[47;31mLV가 생성된 경로를 입력해주세요 (ex. /dev/BackupVG/backup, /dev/DataVG/data) : \033[0m"
read lvpath

#입력받은 파일시스템, LV경로를 변수로 적용시켜 파일 시스템 포멧
mkfs -t "$fsys" "$lvpath"

#입력받은 경로의 유무를 확인하여 생성되지 않은 디렉터리일 경우 디렉터리 생성
echo -e "\033[47;31m마운트 경로를 입력해 주세요 (ex. /data, /backup) : \033[0m"
read mdir

if [ -e "$mdir" ]; then
        echo "$mdir WANRNIG: already exist"
else
        mkdir -p "$mdir"
        echo "$mdir newly created"
fi


#/etc/fstab 파일에 마운트 설정 입력
echo -ne "$lvpath"'\t'"$mdir"'\t'"$fsys"'\t'defaults'\t'0'\t'0 >> /etc/fstab

#/etc/fstab 파일 기반으로 오토 마운팅
mount -a

df -Th