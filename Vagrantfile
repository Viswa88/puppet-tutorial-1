ENV['VAGRANT_DEFAULT_PROVIDER'] = 'docker'
MY_IP=ENV['MY_IP']||`ifconfig eth0 | grep 'inet addr:'| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1}'`

Vagrant.configure(2) do |config|
  config.ssh.private_key_path = File.expand_path("../keys/id_rsa", __FILE__)
  config.ssh.username = "root"
  config.vm.provider "docker" do |d|
    d.build_dir = "."
      d.build_dir = "."
      #d.create_args = ["--cap-add=SYS_PTRACE"]
      d.create_args = ["--privileged=true","--dns="+MY_IP]
#      d.dns_server = ENV['MY_IP']
#      d.name = "base"
      d.remains_running = true
      #d.cmd = ["bash","-c","mkdir /var/run/sshd;chmod 0755 /var/run/sshd; /usr/sbin/sshd -D"]
      d.cmd = ["/sbin/my_init"]
      d.has_ssh = true
  end

  config.berkshelf.enabled = false

  config.vm.define "puppet1" do | base |
    base.vm.host_name              ="puppet1.calavera.biz"
    base.vm.network                 "private_network", ip: "192.168.33.29"
    base.vm.network                 "forwarded_port", guest: 22, host: 2229, auto_correct: true

    base.vm.synced_folder           ".",         "/home/base"
    base.vm.synced_folder           "./shared", "/mnt/shared"
    base.vm.provider "docker" do |d|
      d.name = "puppet1"
    end
  end

  config.vm.define "puppet2" do | base |
    base.vm.host_name              ="puppet2.calavera.biz"
    base.vm.network                 "private_network", ip: "192.168.33.29"
    base.vm.network                 "forwarded_port", guest: 22, host: 2229, auto_correct: true

    base.vm.synced_folder           ".",         "/home/base"
    base.vm.synced_folder           "./shared", "/mnt/shared"
    base.vm.provider "docker" do |d|
      d.name = "puppet2"
    end

  end
  config.vm.define "puppet3" do | base |
    base.vm.host_name              ="puppet3.calavera.biz"
    base.vm.network                 "private_network", ip: "192.168.33.29"
    base.vm.network                 "forwarded_port", guest: 22, host: 2229, auto_correct: true

    base.vm.synced_folder           ".",         "/home/base"
    base.vm.synced_folder           "./shared", "/mnt/shared"
    base.vm.provider "docker" do |d|
      d.name = "puppet3"
    end
  end
end
