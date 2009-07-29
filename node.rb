=begin
Amit Levy
=end

require 'chord_id'

module RChord
  class Node < ChordId
    
    attr_reader :address, :port
    
    def initialize(hash)
      super(hash[:id])
      @address = hash[:address]
      @port = hash[:port]
    end

    def to_s
      "[id => #{id}, address => #{address}, port => #{port}]"
    end
        
    def info
      {:id => @id, :address => address, :port => port}
    end
    
    def export
      Node.new(info)
    end
  end
end
