#!/usr/bin/env ruby

require 'test/unit'
require 'local_node'

module RChord

  class LocalNodeTest < Test::Unit::TestCase
  
    def test_find_successor
      node1 = LocalNode.new({:id => 15})
      node2 = LocalNode.new({:id => 30})
      node1.fingers = [node2, node1, node1]
      node2.fingers = [node1, node2, node2]
    
      assert_equal node2, node1.find_successor(ChordId.new(16))
      assert_equal node1, node1.find_successor(ChordId.new(14))
      assert_equal node2, node2.find_successor(ChordId.new(16))
      assert_equal node1, node2.find_successor(ChordId.new(14))
      
      assert_equal node2, node1.find_successor(ChordId.new(30))
      assert_equal node1, node2.find_successor(ChordId.new(15))
      
      assert_equal node2, node2.find_successor(ChordId.new(30))
      assert_equal node1, node1.find_successor(ChordId.new(15))
    end
    
    def test_notify_predecessor
      node1 = LocalNode.new({:id => 15})
      node2 = LocalNode.new({:id => 30, :predecessor => node1})
      node3 = LocalNode.new({:id => 16})
      node2.notify(node3)
      
      assert_equal node3, node2.predecessor
    end
    
    def test_notify_predecessor_nil
      node1 = LocalNode.new({:id => 15})
      node2 = LocalNode.new({:id => 30})
      node1.notify(node2)
      
      assert_equal node2, node1.predecessor
    end
    
    def test_notify_predecessor_not_correct
      node1 = LocalNode.new({:id => 15})
      node2 = LocalNode.new({:id => 30, :predecessor => node1})
      node3 = LocalNode.new({:id => 35})
      node2.notify(node3)
      
      assert_equal node1, node2.predecessor
    end
  
  end
end

if __FILE__ == $0
  require 'test/unit/ui/console/testrunner'
  Test::Unit::UI::Console::TestRunner.run(RChord::LocalNodeTest)
end
