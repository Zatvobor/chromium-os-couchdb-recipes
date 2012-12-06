namespace :couchdb do

  desc "Push the Couch DB (version 1.2.0) on Chromium OS."
  task :install do
    if ip = ENV['VNODE_IP']
      server ip, :chronos, :sudo
      remount
      delete_tmp_file
      create_tmp_install_folder
      create_couchdb_group
      create_couchdb_user
      get_perms_for_couchdb
      load_init_conf
      load_init_functions
      reload_ip_tables
      delete_tmp_file
      create_symlink
      sudo 'reboot'
    else
      puts "The Shromium node doesn't specified! Use 'cap couchdb:install VNODE_IP=192.168.1.1'"
    end
  end
end

def create_symlink
  sudo "cp -Rp /opt/* /usr/local/opt/"
  sudo "rm -rf /opt"
  sudo "ln -s /usr/local/opt /opt"
end

def reload_ip_tables
  put_sudo File.read('public/ip-tables/iptables.conf'), "/etc/init/iptables.conf"
end

def load_init_conf
  sudo "rm -rf /etc/init/test_sturt.conf"
  put_sudo File.read('public/init-conf/mount_create_couchdb.conf'), "/etc/init/mount_create_couchdb.conf"
end

def load_init_functions
  sudo "mkdir -p /lib/lsb"
  put_sudo File.read('public/couchdb/init-functions'), "/lib/lsb/init-functions"
end


def create_couchdb_group
  sudo "groupadd couchdb"
end

def create_couchdb_user
  sudo "adduser couchdb --system -d /var/lib/couchdb --shell /bin/bash -g couchdb"
end

def get_perms_for_couchdb
  sudo "touch /var/log/couchdb/couch.log"
  sudo "chown -R couchdb:couchdb /var/log/couchdb/"
  sudo "chown -R couchdb:couchdb /etc/couchdb"
  sudo "chown -R couchdb:couchdb /var/lib/couchdb"
  sudo "mkdir -p /var/run/couchdb"
  sudo "chown -R couchdb:couchdb /var/run/couchdb"
end

#first remount system
def remount
  sudo 'mount -o remount rw /'
end

def create_tmp_install_folder
  sudo 'mkdir /install_tmp'
end

def delete_tmp_file
  sudo 'rm -rf /install_tmp'
end