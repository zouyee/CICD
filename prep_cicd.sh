#!/usr/bin/env bash

STRING=`grep -i "ci.localdomain" /etc/hosts`


echo "root user to exec script"
echo "Only for Centos7"
#yum groupinstall 'GNOME Desktop'
echo "change local repo to aliyun repo"
mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup
wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
yum makecache

echo "yum install docker engine"
sudo yum install https://get.docker.com/rpm/1.7.0/fedora-21/RPMS/x86_64/docker-engine-1.7.0-1.fc21.x86_64.rpm
echo "start docker service"
sudo service docker start
echo "run hello-world for test docker status"
sudo docker run hello-world
sudo yum install git python-pip

echo "build docker "
yum install wget -y


sudo docker build -t exzuul .
sudo docker run -d -h ci.localdomain -v /dev/urandom:/dev/random -p 80:80 -p 29418:29418 -p 8080:8080 -p 8081:8081 -p 8888:8888 exzuul

CID=$(sudo docker ps | grep exzuul | cut -f1 -d' ')
PID=$(sudo docker inspect --format '{{ .NetworkSettings.IPAddress }}' $CID)
sed -i '/ci.localdomain/d' /etc/hosts
echo $PID"	ci.localdomain" >>/etc/hosts


echo "enter into docker instance"
sudo docker exec -i -t $CID /bin/bash






