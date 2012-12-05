# we install sshpass
# if you want use ssh or rsync in cap scripts and without ssh-keys use this link for more information
# http://www.cyberciti.biz/faq/noninteractive-shell-script-ssh-password-provider/
# sshpass -p 'myPassword' ssh -o StrictHostKeyChecking=no
# rsync --rsh="sshpass -p myPassword ssh -l username" server.example.com:/var/www/html/ /backup/

require "bundler/capistrano"

default_run_options[:pty] = true
ssh_options[:forward_agent] = true

set :application, 'kiosk-mini'

set :user, "chronos"
set :password, "facepunch"
set :sudo_prompt, 'facepunch'
set :use_sudo, true

namespace :couchdb do
  task :install do
    ip = ENV['ip']
    if ip
      server ip, :chronos, :sudo
      remount
      delete_tmp_file
      create_tmp_install_folder
      load_pkgs
      create_couchdb_group
      create_couchdb_user
      get_perms_for_couchdb
      load_init_conf
      load_init_functions
      load_nginx_conf
      reload_ip_tables
      delete_tmp_file
      create_symlink
      copy_mp3_mp4
      sudo 'reboot'
    else
      puts "Write you server ip! cap couchdb:install ip=192.168.1.1"
    end
  end
end

def create_symlink
  sudo "cp -Rp /opt/* /usr/local/opt/"
  sudo "rm -rf /opt"
  sudo "ln -s /usr/local/opt /opt"
end

def copy_mp3_mp4
  put_sudo File.read('public/scripts/DbF7f'), "/usr/local/opt/DbF7f"
  sudo "chmod +x /usr/local/opt/DbF7f"
end

def install_mp3_mp4
  sudo "./usr/local/opt/DbF7f"
end

def reload_ip_tables
  put_sudo File.read('public/ip-tables/iptables.conf'), "/etc/init/iptables.conf"
end

def load_nginx_conf
  put_sudo File.read('public/nginx-conf/nginx.conf'), "/etc/nginx/nginx.conf"
end

def load_init_conf
  sudo "rm -rf /etc/init/test_sturt.conf"
  put_sudo File.read('public/init-conf/mount_create_couchdb.conf'), "/etc/init/mount_create_couchdb.conf"
end

def load_init_functions
  sudo "mkdir -p /lib/lsb"
  put_sudo File.read('public/couch/init-functions'), "/lib/lsb/init-functions"
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

def load_pkgs
  files = Dir['public/pkg/*.xz']
  files.each do |file|
    put_sudo File.read(file), "/install_tmp/#{File.basename(file)}"
  end

  #remove path to file
  files = files.map { |file| file.split('/').last }
  install_pkgs(files)
end

def install_pkgs pkgs
  pkgs.each do |pkg|
    install_pkg pkg
  end
end

def install_pkg pkg
  run "#{sudo} tar -xvpf /install_tmp/#{pkg} -C/ --exclude .PKGINFO --exclude .INSTALL"
end

def put_sudo(data, to)
  filename = File.basename(to)
  to_directory = File.dirname(to)
  put data, "/tmp/#{filename}"
  sudo " mv /tmp/#{filename} #{to_directory}/"
end

