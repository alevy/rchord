require 'socket'

module RChord
  class UDPTransport
  
    UDP_RECV_TIMEOUT = 3
    
    def initialize(address, port)
      @address = address
      @port = port
    end
    
    def send_msg(msg, *args)
      socket ||= UDPSocket.new
      socket.connect(@address, @port)
      socket.send("#{msg}:#{Marshal.dump(args)}", 0)
      resp = socket.recvfrom(1024) if select([socket], nil, nil, UDP_RECV_TIMEOUT)
      raise "Connection Timed Out" unless resp
      result = Marshal.load(resp[0])
      socket.close
      raise result if result.is_a?(Exception)
      return result
    end
  end
end

