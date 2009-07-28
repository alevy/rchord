#!/usr/bin/env ruby

require 'test/unit'
require 'chord_id'

class ChordIdTest < Test::Unit::TestCase
  
  include RChord
  
  def test_add_id
    one = ChordId.new(100)
    two = ChordId.new(200)
    expected = ChordId.new(300)
    assert_equal expected, one + two
    
    one = ChordId.new(100)
    two = ChordId.new(2**KEY_SIZE - 50)
    expected = ChordId.new(50)
    assert_equal expected, one + two
  end
  
  def test_add_fixnum
    one = ChordId.new(100)
    expected = ChordId.new(300)
    assert_equal expected, one + 200
    
    one = ChordId.new(100)
    expected = ChordId.new(50)
    assert_equal expected, one + (2**KEY_SIZE - 50)
  end
  
  def test_in
    id = ChordId.new(100)
    assert id.in(50, 150)
    assert id.in(151, 150)
    assert id.in(40, 40)
    assert id.in(0, 100)
    assert !id.in(151, 90)
    assert !id.in(50, 60)
  end
  
end

if __FILE__ == $0
  require 'test/unit/ui/console/testrunner'
  Test::Unit::UI::Console::TestRunner.run(ChordIdTest)
end
