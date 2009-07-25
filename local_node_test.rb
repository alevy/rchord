#!/usr/bin/env ruby

require 'test/unit'
require 'local_node'

class LocalNodeTest < Test::Unit::TestCase
  
  def test_find_successor
    assert true
  end
  
end

if __FILE__ == $0
  require 'test/unit/ui/console/testrunner'
  Test::Unit::UI::Console::TestRunner.run(LocalNodeTest)
end
