# This class represents a Docker Swarm Service.
class Docker::Swarm::Service
  include Docker::Base

  class << self
    def get(id, opts = {}, conn = Docker.connection)
      service_json = conn.get("/services/#{URI.encode(id)}", opts)
      hash = Docker::Util.parse_json(service_json) || {}
      new(conn, hash)
    end

    def all(opts = {}, conn = Docker.connection)
      hashes = Docker::Util.parse_json(conn.get('/services', opts)) || []
      hashes.map { |hash| new(conn, hash) }
    end
  end
end
