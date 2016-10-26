class Docker::Swarm; end

require 'docker/swarm/node'
require 'docker/swarm/service'
require 'docker/swarm/task'

# This class represents a Docker Swarm.
class Docker::Swarm
  include Docker::Base

  class << self
    def get(opts = {}, conn = Docker.connection)
      swarm_json = conn.get("/swarm", opts)
      hash = Docker::Util.parse_json(swarm_json) || {}
      new(conn, hash)
    end
  end
end
