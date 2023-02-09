#!/bin/bash

#running 상태 전체 ec2 공인 IP조회
external_ip=$(aws ec2 describe-instances --filters \
    "Name=instance-state-name,Values=running" \
    --output text --query 'Reservations[].Instances[].PublicIpAddress')

# running 상태 전체 ec2 Name 태그 확인 
ec2_name=$(aws ec2 describe-instances \
--filters "Name=instance-state-name,Values=running" \
    --query 'Reservations[*].Instances[*].Tags[?Key==`Name`] .Value' --output text)

# running 상태 전체 ec2 전체 태그 테이블 형식으로 출력 
aws ec2 describe-instances \
--filters "Name=instance-state-name,Values=running" \
    --query 'Reservations[*].Instances[*].Tags[*]' --output table

# running 상태, test로 시작하는 ec2 전체 태그 테이블 출력 
aws ec2 describe-instances \
--filters "Name=instance-state-name,Values=running" \
          "Name=tag:Name, Values=test*"\
    --query 'Reservations[*].Instances[*].Tags[*]' --output table


# running 상태 전체 ec2 Name, 공인 IP 출력
aws ec2 describe-instances \
--filters "Name=instance-state-name,Values=running" \
--query "Reservations[].Instances[].[ Tags[?Key == 'Name'].Value | [0], PublicIpAddress ]" --output text


#running 상태 ec2 키페어명 확인
aws ec2 describe-instances \
--filters "Name=instance-state-name,Values=running" \
    --output text --query 'Reservations[].Instances[].KeyName'

##########################################################

#전체 ec2 공인 IP조회
external_ip=$(aws ec2 describe-instances --filters \
     --output text --query 'Reservations[].Instances[].PublicIpAddress')

#전체 ec2 Name 태그 확인 
ec2_name=$(aws ec2 describe-instances \
    --query 'Reservations[*].Instances[*].Tags[?Key==`Name`] .Value' --output text)

# running 상태 전체 ec2 Name, 공인 IP 출력
aws ec2 describe-instances \
--filters "Name=instance-state-name,Values=running" \
--query "Reservations[].Instances[].[ Tags[?Key == 'Name'].Value | [0], PublicIpAddress ]" --output text

#전체 ec2 전체 태그 테이블 형식으로 출력 
aws ec2 describe-instances \
    --query 'Reservations[*].Instances[*].Tags[*]' --output table

#test로 시작하는 ec2 전체 태그 테이블 출력 
aws ec2 describe-instances \
--filters "Name=tag:Name, Values=test*"\
    --query 'Reservations[*].Instances[*].Tags[*]' --output table

#전체 ec2 키페어명 확인하여 파일 확인
aws ec2 describe-instances \
    --output text --query 'Reservations[].Instances[].KeyName'
