#!/bin/bash
set -x
sudo echo "echo 'nameserver 8.8.8.8' > /etc/resolv.conf" >> /etc/rc.local
sudo echo "yum install  -y java epel-release gcc" >> /etc/rc.local
sudo echo "yum install -y python-devel python-pip" >> /etc/rc.local
sudo echo "pip install zuul" >> /etc/rc.local
sudo echo "sh /opt/nodepool_scripts/base.sh" >> /etc/rc.local
cat  /opt/nodepool_scriptes/hosts >>/etc/hosts
chmod +x /etc/rc.d/rc.local
echo 'nameserver 8.8.8.8' > /etc/resolv.conf
sudo yum makecache
sudo yum install wget -y
echo `date`"install wget ">> /home/1
sudo wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
sudo yum makecache
systemctl disable selinux
sed -i "s/^.*PermitRootLogin.*$/PermitRootLogin yes/g" /etc/ssh/sshd_config
sed -i "s/^.*PubkeyAuthentication.*$/PubkeyAuthentication yes/g" /etc/ssh/sshd_config
sed -i "s/^.*RSAAuthentication.*$/RSAAuthentication yes/g" /etc/ssh/sshd_config
sed -i "s/^.*PermitRootLogin.*$/PermitRootLogin yes/g" /etc/ssh/sshd_config
sed -i "s/^.*PermitEmptyPasswords.*/PermitEmptyPasswords yes/g" /etc/ssh/sshd_config
sed -i "s/^.*PasswordAuthentication.*/PasswordAuthentication yes/g" /etc/ssh/sshd_config
cat /etc/ssh/sshd_config>>/root/1.1
sudo systemctl restart sshd
cat /etc/ssh/sshd_config>>/root/1.2

sudo useradd -m jenkins
sudo gpasswd -a jenkins wheel
echo "jenkins ALL=(ALL) NOPASSWD:ALL" | sudo tee --append /etc/sudoers.d/90-cloud-init-users
echo "Defaults   !requiretty" | sudo tee --append /etc/sudoers.d/90-cloud-init-users

sudo mkdir /home/jenkins/.ssh
mkdir /root/.ssh/
sudo cp /opt/nodepool-scripts/authorized_keys /root/.ssh/authorized_keys
sudo chown -R root:root  /root/.ssh
sudo chmod 700 /root/.ssh
sudo chmod 600 /root/.ssh/authorized_keys

cloud_user=$(egrep " name:" /etc/cloud/cloud.cfg | awk '{print $2}')
cat /opt/nodepool-scripts/authorized_keys | sudo tee -a /home/jenkins/.ssh/authorized_keys
cat /opt/nodepool-scripts/authorized_keys | sudo tee -a /root/.ssh/authorized_keys

# Required by Jenkins
echo "start install java" >> 4.0
yum install -y java
echo "install java" >> 4.0
# zuul-cloner is needed as well
sudo yum install -y epel-release
sudo yum install -y python-pip git python-devel patch
sudo yum install -y gcc
sudo pip install zuul gitdb requests glob2 python-magic argparse python-swiftclient python-keystoneclient

sudo curl -o /usr/local/bin/zuul_swift_upload.py \
    https://raw.githubusercontent.com/openstack-infra/project-config/master/jenkins/scripts/zuul_swift_upload.py
sudo chmod +x /usr/local/bin/zuul_swift_upload.py

sleep 5
cat /etc/hosts >> 1.3

sync
echo "Base setup done."
