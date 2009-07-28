=begin
Amit Levy
=end

require 'node'
require 'remote_node'

Thread.abort_on_exception = true

module RChord
  class LocalNode < Node
  
    attr_accessor :predecessor
    attr_accessor :fingers
  
    def initialize(hash)
      super(hash)
      @fingers = hash[:fingers] || Array.new(KEY_SIZE, self)
      @predecessor = hash[:predecessor]
    end
  
    def successor
      @fingers[0]
    end
  
    def successor=(s)
      @fingers[0] = s
    end
  
    ####################
    # Chord Operations #
    ####################
  
    def find_successor(n)
      n = ChordId.new(n.id)
      if predecessor and n.in(predecessor, self)
        self
      elsif n.in(self, successor)
        successor
      else
        pred = closest_preceding_node(n)
        while not n.in(pred, pred.successor)
          pred = pred.closest_preceding_node(n)
        end
        pred.successor
      end
    end
  
    def join(n)
      @predecessor = nil
      @fingers[0] = n.find_successor(ChordId.new(self.id))
    end
  
    def notify(n)
      n = RemoteNode.new(n) if n.is_a?(Hash)
      @predecessor = n if not predecessor or n.in(predecessor, self)
    end
  
    def stabalize
      x = successor.predecessor
      @fingers[0] = x if x and x.in(self, successor)
      if @fingers[0].is_a?(LocalNode)
        @fingers[0].notify(self)
      else
        @fingers[0].notify(self.info)
      end
    end
  
    def fix_fingers
      @_next_finger ||= 0
      @_next_finger = (@_next_finger + 1) % KEY_SIZE
      @fingers[@_next_finger] = find_successor(self + 2**@_next_finger)
    end
  
    def check_predecessor
      predecessor = nil unless predecessor and predecessor.ping
    end
  
    def ping
      true
    end
    
    def start
      t1 = Thread.new do
        loop do
          begin
            stabalize
          rescue
            @fingers[0] = self
          end
          sleep 0.05
        end
      end
      t2 = Thread.new do
        loop do
          begin
            fix_fingers
          rescue
          end
          sleep 0.05
        end
      end
      t2 = Thread.new do
        loop do
          begin
            check_predecessor
          rescue
            predecessor = nil
          end
          sleep 0.05
        end
      end
    end

    def closest_preceding_node(n)
      for finger in @fingers.reverse
        return finger if finger.in(self, n - 1)
      end
      return self
    end
  end
end
