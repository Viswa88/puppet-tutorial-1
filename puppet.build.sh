#!/bin/bash
NIC="eth0"
name="dnsmasq"
export MY_IP=$(ifconfig $NIC | grep 'inet addr:'| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1}')

echo -n "[agent]
server=${HOSTNAME}.calavera.biz
" > puppet.conf

> /data/devops/Calavera/dnsmasq.hosts/puppet
pushd `dirname $0`
export USER=root
echo "-- Ceating the puppet testing machines"
for NODE in puppet1 puppet2 puppet3 
do
    docker stop $NODE > /dev/null 2>&1
    docker rm $NODE > /dev/null 2>&1
    vagrant destroy -f $NODE
    puppet cert clean ${NODE}.calavera.biz
    echo "-- Building \"${NODE}\""
    vagrant up --no-provision ${NODE}
    echo "-- Adding \"${NODE}\" to dns"
    C_IP=`docker inspect --format='{{.NetworkSettings.IPAddress}}' ${NODE}`
    echo "${C_IP} ${NODE} ${NODE}.calavera.biz" >> /data/devops/Calavera/dnsmasq.hosts/puppet
    docker kill -s HUP dnsmasq
    echo "-- Adding to puppet master"
    ssh root@${NODE} -o "StrictHostKeyChecking no" "puppet agent -t"
    puppet cert sign --all
    ssh root@${NODE} -o "StrictHostKeyChecking no" "puppet agent -t"
    ssh root@${NODE} -o "StrictHostKeyChecking no" "echo 'START=yes' > /etc/default/puppet"
    ssh root@${NODE} -o "StrictHostKeyChecking no" "service puppet start"
done
popd
