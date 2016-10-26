require 'net/ssh'
require 'shellwords'
require 'json'
require 'paint'
require 'date'
require 'ostruct'

require 'docker-pier/log-stream/palette'

class Pathname
  def to_shell
    Shellwords.escape(self.to_s)
  end
end

class DockerPier::LogStream
  def initialize(pier)
    @pier = pier
    @palette = DockerPier::LogStream::Palette.new
    @task_colors = Hash.new{ |h,k| h[k] = @palette.draw! }
  end

  def path
    @path ||= get_path!
  end

  def get_path!
    logs_dir = Pathname.new '/var/log/fluentd'
    logfile_link = logs_dir + 'docker.log'

    # fluentd creates the symlink with an absolute path from inside a container,
    # so the dir the link points to is wrong. We assume the logs dir instead.
    logs_link_dest = Pathname.new(@pier.ssh.exec!("readlink #{logfile_link.to_shell}").chomp)
    logs_dir + logs_link_dest.basename
  end

  def parse_log_ln(ln)
    ts, fluent_source_id, event_json = ln.split(/\s+/, 3)

    ts = DateTime.parse(ts)
    event = JSON.parse(event_json)
    event_type = (event.delete('source') == 'stderr') ? :error : :output

    container_id = event.delete('container_name')[1..-1]
    msg = event.delete('log')

    if msg[0] == '{'
      msg_parts = JSON.parse(msg)
      msg_lns = msg_parts.delete('lines').map{ |ln| ln.chomp }
      msg_parts = OpenStruct.new(msg_parts)
    else
      msg_lns = msg.split("\n")
    end

    service_parts = container_id.match(/^(\w+)\.(\d+)\.(\w+)$/)
    service = service_parts ? [service_parts[1], service_parts[2].to_i] : nil

    task_handle = service ? ("%s[%02d]" % service) : container_id
    task_color = @task_colors[task_handle]

    OpenStruct.new(
      time: ts,
      type: event_type,
      service: service,
      task: OpenStruct.new(name: task_handle, color: task_color),
      location: [:some_node, container_id],
      message: msg_parts,
      lines: msg_lns
    )
  end

  def stream!
    ssh_session = @pier.ssh

    channel = ssh_session.open_channel do |ch|
  		ch.exec "tail -f #{self.path.to_shell}" do |ch, success|
        raise "could not tail logs on remote" unless success

        ch.on_data do |_, data|
          data.split("\n").each do |ln|
            event = parse_log_ln(ln)
            yield(event)
          end
        end
      end
    end

    int_pressed = false
    trap("INT") { int_pressed = true }
    ssh_session.loop(0.1) { not int_pressed }

    ssh_session.shutdown!
  end
end
