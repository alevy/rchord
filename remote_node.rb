=begin
Amit Levy
=end

require 'node'
require 'socket'
require 'local_node'

module RChord
  class RemoteNode < Node
    
    UDP_RECV_TIMEOUT = 3
    
    def initialize(hash)
      @id = hash[:id]
      @address = hash[:address]
      @port = hash[:port]
    end
    
    def id
      @id ||= method_missing("id")
    end
  
    def method_missing(msg, *args)
      socket ||= UDPSocket.new
      socket.connect(@address, @port)
      socket.send("#{msg}:#{Marshal.dump(args)}", 0)
      resp = socket.recvfrom(1024) if select([socket], nil, nil, UDP_RECV_TIMEOUT)
      raise "Connection Timed Out" unless resp
      return Marshal.load(resp[0])
    end
  end
end
