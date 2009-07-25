=begin
Amit Levy
=end

require 'chord_id'

class LocalNode < ChordId
  
  attr_accessor :predecessor
  
  def initialize(hash)
    @id = hash[:id]
    @address = hash[:address]
    @port = hash[:port]
    @fingers = hash[:fingers] || Array.new(64, self)
    @predecessor = hash[:predecessor]
  end
  
  def to_s
    "id => #{@id}, address => #{@address}, port => #{@port}"
  end
  
  def successor
    @fingers.first
  end
  
  def successor=(s)
    @fingers[0] = s
  end
  
  ####################
  # Chord Operations #
  ####################
  
  def find_successor(n)
    if n.in(self, successor)
      successor
    else
      closest_preceding_node(n).find_successor(n)
    end
  end
  
  def join(n)
    predecessor = nil
    successor = find_successor(self)
  end
  
  def notify(n)
    predecessor = n if not predecessor or n.in(predecessor, self)
  end
  
  def stabalize
    x = successor.predecessor
    successor = x if x.in(self, successor)
    successor.notify
  end
  
  def fix_fingers
    @_next_finger ||= 0
    @_next_finger = (@next + 1) % 64
    @fingers[@_next_finget] = find_successor(n + 2**@_next_finger)
  
private
  
  def closest_preceding_node(n)
    for finger in @fingers.reverse
      return finger if finger.in(self, n)
    end
    return self
  end
end