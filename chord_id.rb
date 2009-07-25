module RChord
  
  KEY_SIZE = 128
  
  class ChordId
  
    include Comparable
  
    attr_accessor :id
  
    def initialize(id)
      @id = id
    end
  
    def in(x, y)
      if x == y
        true;
      elsif (y < id)
        x > y && x < id;
      else
        x < y && x < id || x > y && x > id;
      end
    end
  
    def <=>(other)
      @id<=>(other.id)
    end
  
    def +(other)
      return ChordId.new((@id + other.id) % 2**KEY_SIZE) if other.is_a?(ChordId)
      return ChordId.new((@id + other) % 2**KEY_SIZE)
    end
  end
end