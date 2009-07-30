=begin
Amit Levy
=end

require 'rchord/node'
require 'rchord/transport'

module RChord
  class RemoteNode < Node
    
    def initialize(hash, transport=Transport::UDPTransport.new(hash[:address], hash[:port]))
      @id = hash[:id]
      @address = hash[:address]
      @port = hash[:port]
      @transport = transport
    end
    
    def id
      @id ||= @transport.send_msg("id")
    end
    
    def successor
      RemoteNode.new(@transport.send_msg("successor"))
    end
    
    def find_successor(n)
      RemoteNode.new(@transport.send_msg("find_successor", n.id))
    end
    
    def notify(n)
      @transport.send_msg("notify", n.info)
    end
    
    def closest_preceding_node(n)
      RemoteNode.new(@transport.send_msg("closest_preceding_node", n.id))
    end
    
    def ping
      @transport.send_msg("ping")
    end
    
    def predecessor
      result = @transport.send_msg("predecessor")
      RemoteNode.new(result) if result
    end
  end
end

