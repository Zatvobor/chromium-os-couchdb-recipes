require 'socket'
class Capistrano::Configuration

  def fetch_local_ip
    orig, Socket.do_not_reverse_lookup = Socket.do_not_reverse_lookup, true # turn off reverse DNS resolution temporarily
    UDPSocket.open do |s|
      s.connect '64.233.187.99', 1
      s.addr.last
    end
  ensure
    Socket.do_not_reverse_lookup = orig
  end

  def put_sudo(data, to)
    filename = File.basename(to)
    to_directory = File.dirname(to)
    put data, "/tmp/#{filename}"
    sudo " mv /tmp/#{filename} #{to_directory}/"
  end

end
