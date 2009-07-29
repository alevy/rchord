=begin
Amit Levy
=end

require 'socket'
require 'rchord/remote_node'

module RChord
  class ChordUdpServer

    class NodeWrapper
      def initialize(node)
        @node = node
      end
      
      def successor
        @node.successor.info
      end
      
      def find_successor(n)
        @node.find_successor(ChordId.new(n)).info
      end
      
      def closest_preceding_node(n)
        @node.closest_preceding_node(ChordId.new(n)).info
      end
      
      def predecessor
        pred = @node.predecessor
        pred.info if pred
      end
      
      def notify(n)
        @node.notify(RemoteNode.new(n))
      end
      
      def id
        @node.id
      end
      
      def method_missing(name, *args)
        @node.send(name, *args)
      end
    end

    def initialize(node)
      @node = NodeWrapper.new(node)
      @socket = UDPSocket.new
      @socket.bind(node.address, node.port)
    end
    
    def listen
      text, sender = @socket.recvfrom(1024)
      begin
        match = text.match(/^([a-z_]+):(.+)/)
        return nil unless match # if message is malformed, just return
        method = match[1]
        args = Marshal.load(match[2])
        result = @node.send(method, *args)
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
  node.join(rnode)
  node.start
  puts node
  t1.join
end

