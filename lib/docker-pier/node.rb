require 'docker-pier/version'
require 'fog/libvirt'
require 'docker/swarm'
require 'json'

class DockerPier::Node < SimpleDelegator
	def initialize(docker_node, pier)
		@docker_node = docker_node
		@pier = pier
		super @docker_node
	end

	def libvirt_node
		@libvirt_node ||= (@pier.libvirt.servers.all(name: @docker_node.info['Description']['Hostname']).first rescue nil)
	end

	def inspect
		"#<DockerPier::Node %s/%s>" % [@pier.name, @docker_node.info['Description']['Hostname']]
	end
end
