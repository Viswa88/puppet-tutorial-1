#!/bin/bash
NIC="eth0"
if [ -z "$CALAVERA_HOME" ]; then
   export CALAVERA_HOME="/opt/Calavera-chef-provision"
fi
pushd `dirname $0`
[ ! -d slaves ] && mkdir slaves
[ ! -d master ] && mkdir master
cp Dockerfile.slaves slaves/Dockerfile
cp puppet.conf.slaves slaves/puppet.conf
cp Dockerfile.master master/Dockerfile
cp -R $CALAVERA_HOME/shared slaves
cp -R $CALAVERA_HOME/shared master
cp -R shared/*.deb master/shared
cp -R shared/*.deb slaves/shared
name="dnsmasq"
export MY_IP=$(ifconfig $NIC | grep 'inet addr:'| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1}')


echo -n "[agent]
server=puppetmaster.calavera.biz
" > slaves/puppet.conf

> ${CALAVERA_HOME}/dnsmasq.hosts/puppet
# puppet master
echo "-- Creating the puppet master machines"
NODE=puppetmaster

    docker stop $NODE > /dev/null 2>&1
    docker rm $NODE > /dev/null 2>&1
    docker images|grep "^<none"|awk '{print $3}'|xargs docker rmi -f > /dev/null 2>&1
    vagrant destroy -f $NODE
    echo "-- Building \"${NODE}\""
    vagrant up --no-provision ${NODE}
    echo "-- Adding \"${NODE}\" to dns"
    C_IP=`docker inspect --format='{{.NetworkSettings.IPAddress}}' ${NODE}`
    echo "${C_IP} ${NODE} puppet ${NODE}.calavera.biz" >> ${CALAVERA_HOME}/dnsmasq.hosts/puppet
    docker kill -s HUP dnsmasq
    ssh -i shared/keys/id_rsa root@puppetmaster -o "StrictHostKeyChecking no" "timeout 20 puppet master --verbose --no-daemonize"
    ssh -i shared/keys/id_rsa root@puppetmaster -o "StrictHostKeyChecking no" "/etc/init.d/apache2 start"

# puppet slaves
export USER=root
echo "-- Creating the puppet testing machines"
for NODE in puppet1 puppet2 puppet3 
do
    docker stop $NODE > /dev/null 2>&1
    docker rm $NODE > /dev/null 2>&1
    docker images|grep "^<none"|awk '{print $3}'|xargs docker rmi -f > /dev/null 2>&1
    vagrant destroy -f $NODE
    ssh -i shared/keys/id_rsa root@puppetmaster -o "StrictHostKeyChecking no" "puppet cert clean ${NODE}.calavera.biz"
    #puppet cert clean ${NODE}.calavera.biz
    echo "-- Building \"${NODE}\""
    vagrant up --no-provision ${NODE}
    echo "-- Adding \"${NODE}\" to dns"
    C_IP=`docker inspect --format='{{.NetworkSettings.IPAddress}}' ${NODE}`
    echo "${C_IP} ${NODE} ${NODE}.calavera.biz" >> ${CALAVERA_HOME}/dnsmasq.hosts/puppet
    docker kill -s HUP dnsmasq
    echo "-- Adding to puppet master"
    echo "-- step 1"
    ssh -i shared/keys/id_rsa root@${NODE} -o "StrictHostKeyChecking no" "puppet agent -t"
    echo "-- step 2"
    ssh -i shared/keys/id_rsa root@puppetmaster -o "StrictHostKeyChecking no" "puppet cert sign --all"
    echo "-- step 3"
    ssh -i shared/keys/id_rsa root@${NODE} -o "StrictHostKeyChecking no" "puppet agent -t"
    echo "-- step 4"
    ssh -i shared/keys/id_rsa root@${NODE} -o "StrictHostKeyChecking no" "echo 'START=yes' > /etc/default/puppet"
    echo "-- step 5"
    ssh -i shared/keys/id_rsa root@${NODE} -o "StrictHostKeyChecking no" "service puppet start"
done
popd
