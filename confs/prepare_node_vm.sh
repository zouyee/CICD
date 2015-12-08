#!/bin/bash -x
sudo useradd -m jenkins
sudo gpasswd -a jenkins root

# disable selinux and iptables
sudo systemctl disable selinux
echo `whoami`
chkconfig iptables disable


#  permit rootlogin via ssh
echo "change config to allow root ssh"
sed -i "s/.*PermitRootLogin.*/PermitRootLogin yes/g" /etc/ssh/sshd_config
sed -i "s/.*PubkeyAuthentication.*/PubkeyAuthentication yes/g" /etc/ssh/sshd_config
sudo service sshd restart


# change repo and make cache
mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup
wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
yum makecache

yum install epel-release -y

# ssh mutual trust
sudo mkdir -p /root/.ssh

cat > tmp_authorized_keys << INNEREOF
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDCnOmvIg/7CsIxDiHWK6Jbwvu3x4gxtGrend9w6cssVZEyD2VRbLGMh/bsFHp2Y+FZaTM02IBHZ8T/mcXYZz9YJGSba9a8qDGD/xSe9orkNQ/XNRr0V6rBuJcDarW7WKlWHW2kQ623G82OoL00DUiXoYtGUBScVIJj/kVgsNe0AAvsxlbaLO81CtvMTKU47u5MMdaT+rOP6b4+vRR0UYD0N7Kpp2ObV8Q9DBMJDVtLlSCtKSTZz/mgZSq5fEnmxB9BXF450+kAy/f0ZwJFYDZxrC3UUM1XadB8xqKa3ml8oaXxbQ3MlqLC6fh4KdKrT+lQC199kENCPRCtqsuQcdAP root@ci.localdomain
INNEREOF
sudo mv tmp_authorized_keys /root/.ssh/authorized_keys
sudo chmod 700 /root/.ssh
sudo chmod 600 /root/.ssh/authorized_keys
sudo chown -R root:root /root/.ssh

# Required by Jenkins
sudo yum install -y java

# zuul-cloner is needed as well
sudo yum install -y python-pip git python-devel gcc patch
sudo pip install zuul gitdb requests glob2 python-magic argparse python-swiftclient python-keystoneclient

# python-jenkins need 0.4.3
sudo yum install python-pip -y
sudo pip install "python-jenkins<=0.4.3" -y

# for jenkins connect package
sudo yum install -y git python-augeas bridge-utils curl lxc wget swig python-devel python-pip graphviz python-yaml openssl-devel libffi-devel pigz mysql-devel openldap-devel qemu-img libvirt-daemon-lxc git-review
sudo pip install flake8 bash8 ansible
sudo pip install -U tox==1.6.1 Sphinx oslosphinx virtualenv restructuredtext_lint python-swiftclient

# pep8 need these packages
sudo yum install -y libxml2-python libxml2-devel libxslt-python libxslt-devel

# check selinux
sudo sed -i 's/^.*SELINUX=.*$/SELINUX=disabled/' /etc/selinux/config

# change /etc/hosts

sudo cat /etc/hosts /opt/jenkins/slave_scripts/hosts > /etc/hosts

sleep 5
sync
