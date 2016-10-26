# This class represents a Docker Swarm Task.
class Docker::Swarm::Task
  include Docker::Base

  def service
    Docker::Service.get(self.info["ServiceID"])
  end

  def node
    Docker::Node.get(self.info["NodeID"])
  end

  def state
    self.info['Status']['State'].intern
  end

  def running?
    self.state == :running
  end

  class << self
    def get(id, opts = {}, conn = Docker.connection)
      task_json = conn.get("/tasks/#{URI.encode(id)}", opts)
      hash = Docker::Util.parse_json(task_json) || {}
      new(conn, hash)
    end

    def all(opts = {}, conn = Docker.connection)
      hashes = Docker::Util.parse_json(conn.get('/tasks', opts)) || []
      hashes.map { |hash| new(conn, hash) }
    end
  end
end
