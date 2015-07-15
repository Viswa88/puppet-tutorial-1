service apache2 stop
rm -rf /etc/puppet/ssl
cat /etc/puppet/puppet.conf | sed -e '/certname.*$/d' -e '/dns_alt_names.*$/d'|sed 's/\[master\]/\[master\]\ncertname = puppet\ndns_alt_names ='$HOSTNAME','$HOSTNAME'.calavera.biz,puppet\n/g' > /tmp/puppet.conf
mv /tmp/puppet.conf /etc/puppet/puppet.conf
echo "Press <CTRL>-C when finished generation"
puppet master --verbose --no-daemonize 
service apache2 start
