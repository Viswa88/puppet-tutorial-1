service apache2 stop
rm -rf /var/lib/puppet/ssl/*
HSTNAME=`echo $HOSTNAME|tr '[:upper:]' '[:lower:]'`
cat /etc/puppet/puppet.conf | sed -e '/certname.*$/d' -e '/dns_alt_names.*$/d'|sed 's/\[master\]/\[master\]\ncertname = '"$HSTNAME"'.calavera.biz\ndns_alt_names ='$HSTNAME','$HSTNAME'.calavera.biz,puppet\n/g' > /tmp/puppet.conf
mv /tmp/puppet.conf /etc/puppet/puppet.conf
echo "Press <CTRL>-C when finished generation"
puppet master --verbose --no-daemonize 
service apache2 start
