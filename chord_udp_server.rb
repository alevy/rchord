=begin
Amit Levy
=end

require 'socket'
require 'remote_node'

module RChord
  class ChordUdpServer

    def initialize(node)
      @node = node
      @socket = UDPSocket.new
      @socket.bind(node.address, node.port)
    end
    
    def listen
      text, sender = @socket.recvfrom(1024)
      match = text.match(/^([a-z_]+):(.+)/)
      method = match[1]
      args = Marshal.load(match[2])
      #puts sender.values_at(3,1).inspect
      begin
        result = @node.send(method, *args)
        result = RemoteNode.new(result.info) if result.is_a?(Node)
        @socket.send(Marshal.dump(result), 0, *sender.values_at(3,1))
      rescue
        @socket.send(Marshal.dump($!), 0, *sender.values_at(3,1))
      end
    end
    
    def start
      loop do
        listen
      end
    end
    
  end

end

if __FILE__ == $0
  require 'local_node'
  require 'remote_node'
  include RChord
  node = LocalNode.new({:id => rand(2**KEY_SIZE), :address => ARGV[0], :port => ARGV[1].to_i})
  if ARGV.size > 3
    rnode = RemoteNode.new(:address => ARGV[2], :port => ARGV[3].to_i)
  else
    rnode = node
  end
  serv = ChordUdpServer.new(node)
  t1 = Thread.new { serv.start }
  puts node.join(rnode)
  node.start
  puts node
  t1.join
end