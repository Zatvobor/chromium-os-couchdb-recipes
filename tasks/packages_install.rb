namespace :packages do
  desc "Install predefined packages, check public/pkg for more."
  task :install do
    if ip = ENV['VNODE_IP']
      server ip, :chronos, :sudo

      sudo 'mount -o remount rw /'
      sudo 'mkdir -p /install_tmp'

      files = Dir['public/pkg/*.xz']

      files.each do |file|
        put_sudo File.read(file), "/install_tmp/#{File.basename(file)}"
      end

      #remove path to file
      files = files.map { |file| file.split('/').last }
      #install
      install_pkgs(files)

      sudo 'rm -rf /install_tmp'
    else
      puts "The Shromium node doesn't specified! Use 'cap couchdb:install VNODE_IP=192.168.1.1'"
    end
  end

  def install_pkgs pkgs
    pkgs.each do |pkg|
      install_pkg(pkg) if Capistrano::CLI.ui.ask("Install a '#{pkg}' package? [y/n]") == 'y'
    end
  end

  def install_pkg pkg
    run "#{sudo} tar -xvpf /install_tmp/#{pkg} -C/ --exclude .PKGINFO --exclude .INSTALL"
  end
end