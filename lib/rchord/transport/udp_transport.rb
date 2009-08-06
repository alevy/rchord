require 'socket'

module RChord
  module Transport
    class UDPTransport
    
      UDP_RECV_TIMEOUT = 3
      
      def initialize(hash = {})
        @timeout = hash[:timeout] || UDP_RECV_TIMEOUT
        @serializer = hash[:serializer] || Marshal
      end
      
      def bind(address, port)
        @socket = UDPSocket.new
        @socket.bind(address, port)
      end
      
      def listen
        text, sender = @socket.recvfrom(1024)
        begin
          result = yield(*@serializer.load(text))
          @socket.send(@serializer.dump(result), 0, *sender.values_at(3,1))
        rescue
          @socket.send(@serializer.dump($!), 0, *sender.values_at(3,1))
        end
      end
      
      def send_msg(address, port, msg, *args)
        socket = UDPSocket.new
        socket.connect(address, port)
        socket.send(@serializer.dump([msg,args]), 0)
        resp = socket.recvfrom(1024) if select([socket], nil, nil, @timeout)
        raise "Connection Timed Out" unless resp
        result = @serializer.load(resp[0])
        socket.close
        raise result if result.is_a?(Exception)
        return result
      end
    end
  end
end

