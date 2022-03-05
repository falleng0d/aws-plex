#!/bin/bash -xe
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

until [[ $(which aptdcon) ]]; do echo 'Waiting for aptdcon installation...'; sleep 5; done

add-apt-repository -y ppa:jcfp/sab-addons
aptdcon --refresh

yes | aptdcon --hide-terminal --install "sabnzbdplus" "python-sabyenc" "par2-tbb" "p7zip-full"

sed -i "s/^USER=.*/USER=root/g" /etc/default/sabnzbdplus
sed -i "s/^HOST=.*/HOST=0.0.0.0/g" /etc/default/sabnzbdplus
sed -i "s/^PORT=.*/PORT=8080/g" /etc/default/sabnzbdplus

systemctl enable sabnzbdplus
systemctl restart sabnzbdplus
