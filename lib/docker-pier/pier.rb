require 'docker-pier/version'
require 'docker'
require 'docker/swarm'
require 'fog/libvirt'
require 'net/ssh'
require 'net/scp'
require 'resolv'
require 'pathname'

class DockerPier::Pier
  def self.current
    @current ||= self.new(ENV['PIER'])
  end

  def initialize(pier_uri, opts = {})
    @name = opts.delete(:name) || ENV['DOCKER_MACHINE_NAME'] || Digest::SHA1.hexdigest(pier_uri)

    pier_uri = URI.parse(pier_uri.to_s) unless pier_uri.kind_of?(URI)

    @libvirt_uri = pier_uri.dup.tap do |uri|
      uri.scheme = 'qemu+ssh'
      uri.path = '/system'
      uri.query = 'socket=/var/run/libvirt/libvirt-sock'
    end

    @docker_uri = pier_uri.dup.tap do |uri|
      uri.scheme = 'tcp'
      uri.user = nil
      uri.port = 2376
      uri.path = '/'
    end

    @ssh_uri = pier_uri.dup.tap do |uri|
      uri.scheme = 'ssh'
      uri.port = 22
      uri.path = '/'
    end
  end

  attr_reader :name
  attr_reader :libvirt_uri
  attr_reader :docker_uri
  attr_reader :ssh_uri

  def ssh_connstring
    host_part = @ssh_uri.hostname
    host_part = ("%s@%s" % [@ssh_uri.user, host_part]) if @ssh_uri.user
    host_part = ("-p %d %s" % [@ssh_uri.port, host_part]) if (@ssh_uri.port and @ssh_uri.port != 22)
    host_part
  end

  def x509_dir
    Pathname.new(ENV['HOME']) + '.docker-pier' + 'x509' + @name
  end

  def resolved_docker_uri
    @docker_uri.dup.tap{ |u| u.host = Resolv.getaddress(u.host) }
  end


  def libvirt
    @libvirt ||= Fog::Compute.new(provider: "Libvirt", libvirt_uri: @libvirt_uri.to_s)
  end

  def docker
    @docker ||= Docker::Connection.new(self.resolved_docker_uri.to_s,
      scheme: "https",
      ssl_ca_file: (self.x509_dir + "ca.pem").to_s,
      client_cert: (self.x509_dir + "cert.pem").to_s,
      client_key: (self.x509_dir + "key.pem").to_s
    )
  end

  def ssh
    @ssh ||= Net::SSH.start(@ssh_uri.hostname, @ssh_uri.user, password: @ssh_uri.password)
  end


  def bootstrap!
    own_hostname = `hostname -f`.chomp
    remote_export_path = Pathname.new('/var/lib/private-x509/clients') + "#{own_hostname}.tar"

    self.ssh.exec!(<<~EOF)
      if [ ! -f '#{remote_export_path}' ]; then
        /var/lib/private-x509/gen_bundle '#{own_hostname}'
      fi
    EOF

    local_export_path = self.x509_dir + 'export.tar'

    self.x509_dir.mkpath
    Dir.chdir(self.x509_dir.to_s) do
      self.ssh.scp.download! remote_export_path.to_s, local_export_path.to_s
      system 'tar', '-x', '-f', local_export_path.to_s
      local_export_path.unlink
    end
  end


  def nodes
    docker_nodes = Docker::Swarm::Node.all({}, self.docker)
    docker_nodes.map{ |d| DockerPier::Node.new(d, self) }
  end

  def logs
    DockerPier::LogStream.new(self)
  end
end
