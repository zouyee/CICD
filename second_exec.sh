CID=$(sudo docker ps | grep exzuul | cut -f1 -d' ')
PID=$(sudo docker inspect --format '{{ .NetworkSettings.IPAddress }}' $CID)
sed -i '/ci.localdomain/d' /etc/hosts
echo $PID"	ci.localdomain" >>/etc/hosts


echo "enter into docker instance"
sudo docker exec -i -t $CID /bin/bash
