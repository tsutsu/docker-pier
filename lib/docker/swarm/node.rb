require 'json'

# This class represents a Docker Swarm Node.
class Docker::Swarm::Node
  include Docker::Base

  class << self
    def get(id, opts = {}, conn = Docker.connection)
      node_json = conn.get("/nodes/#{URI.encode(id)}", opts)
      hash = Docker::Util.parse_json(node_json) || {}
      new(conn, hash)
    end

    def by_name(node_name, opts = {}, conn = Docker.connection)
      opts = opts.merge(filters: {"name" => [node_name]}.to_json)
      hashes = Docker::Util.parse_json(conn.get('/nodes', opts)) || []
      hash = hashes.first
      new(conn, hash) if hash
    end

    def all(opts = {}, conn = Docker.connection)
      hashes = Docker::Util.parse_json(conn.get('/nodes', opts)) || []
      hashes.map { |hash| new(conn, hash) }
    end
  end
end
