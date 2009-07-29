=begin
Amit Levy
=end

require 'rchord/node'

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
      old = @fingers[0]
      @fingers[0] = s
      puts "Successor changed to #{s}" if old != s
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
      self.predecessor = nil
      self.successor = n.find_successor(self)
    end
  
    def notify(n)
      if not predecessor or n.in(predecessor, self)
        self.predecessor = n
        true
      else
        false
      end
    end
  
    def stabalize
      x = successor.predecessor
      self.successor = x if x and x.in(self, successor)
      successor.notify(self)
    end
  
    def fix_fingers
      @_next_finger ||= 0
      @_next_finger = (@_next_finger + 1) % KEY_SIZE
      @fingers[@_next_finger] = find_successor(self + 2**@_next_finger)
    end
  
    def check_predecessor
      self.predecessor = nil unless predecessor and predecessor.ping
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
            self.successor = self
            $stderr.puts "stabalize: #{$!} #{predecessor}"
          end
          sleep 0.05
        end
      end
      t2 = Thread.new do
        loop do
          begin
            fix_fingers
          rescue
            $stderr.puts "fix_fingers: #{$!}"
          end
          sleep 0.05
        end
      end
      t2 = Thread.new do
        loop do
          begin
            check_predecessor
          rescue
            $stderr.puts "check_predecessor: #{$!}"
            self.predecessor = nil
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

