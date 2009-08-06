=begin
Amit Levy
=end

require 'rchord/node'
require 'rchord/transport'

module RChord
  class RemoteNode < Node
    
    def initialize(hash)
      @id = hash[:id]
      @address = hash[:address]
      @port = hash[:port]
      @transport = hash[:transport] || Transport::UDPTransport.new
    end
    
    def id
      @id ||= send_msg("id")
    end
    
    def successor
      RemoteNode.new(send_msg("successor").merge(:transport => @transport))
    end
    
    def find_successor(n)
      RemoteNode.new(send_msg("find_successor", n.id).merge(:transport => @transport))
    end
    
    def notify(n)
      send_msg("notify", n.info)
    end
    
    def closest_preceding_node(n)
      RemoteNode.new(send_msg("closest_preceding_node", n.id).merge(:transport => @transport))
    end
    
    def ping
      send_msg("ping")
    end
    
    def predecessor
      result = send_msg("predecessor")
      RemoteNode.new(result.merge(:transport => @transport)) if result
    end
    
    private
    def send_msg(*args)
      @transport.send_msg(@address, @port, *args)
    end
  end
end

