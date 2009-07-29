module RChord
  
  KEY_SIZE = ENV['RCHORD_KEY_SIZE'] || 128
  
  class ChordId
  
    include Comparable
  
    attr_accessor :id
  
    def initialize(id)
      raise "Id must be an Integer, not #{id.class}" unless id.is_a?(Integer)
      @id = id
    end
  
    def in(x, y)
      x = ChordId.new(x) unless x.is_a?(ChordId)
      y = ChordId.new(y) unless y.is_a?(ChordId)
      if x == y
        true;
      elsif (y < self)
        x > y && x < self;
      else
        x < y && x < self || x > y && x > self;
      end
    end
  
    def <=>(other)
      raise "#{other.class} not a chord id!" unless other.is_a?(ChordId)
      @id<=>(other.id)
    end
  
    def +(other)
      return ChordId.new((@id + other.id) % 2**KEY_SIZE) if other.is_a?(ChordId)
      return ChordId.new((@id + other) % 2**KEY_SIZE)
    end
    
    def -(other)
      return ChordId.new((@id - other.id) % 2**KEY_SIZE) if other.is_a?(ChordId)
      return ChordId.new((@id - other) % 2**KEY_SIZE)
    end
    
    def to_s
      @id.to_s
    end
  end
end
