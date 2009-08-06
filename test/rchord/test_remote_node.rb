#!/usr/bin/env ruby

require File.dirname(__FILE__) + "/../test_helper"

module RChord

  class RemoteNodeTest < Test::Unit::TestCase
  
    def test_find_successor_id
      result_node_hash = {:id => 5, :address => "www.example.com", :port => 5432}
      id = ChordId.new(1)
      transport = mock()
      transport.expects(:send_msg).with("example.com", 1234, "find_successor", 1).returns(result_node_hash)
      
      rnode = RemoteNode.new(:address => "example.com", :port => 1234, :transport => transport)
      assert_equal RemoteNode.new(result_node_hash),
                   rnode.find_successor(id)
    end
    
    def test_find_successor_node
      result_node_hash = {:id => 5, :address => "www.example.com", :port => 5432}
      input_node_hash = {:id => 7, :address => "next.example.com", :port => 8765}
      transport = mock()
      transport.expects(:send_msg).with("example.com", 1234, "find_successor", 7).returns(result_node_hash)
      
      rnode = RemoteNode.new(:address => "example.com", :port => 1234, :transport => transport)
      assert_equal RemoteNode.new(result_node_hash),
                   rnode.find_successor(Node.new(input_node_hash))
    end
    
    def test_notify
      transport = mock()
      remote_node_hash = {:id => 5, :address => "www.example.com", :port => 5432, :transport => transport}
      input_node_hash = {:id => 1, :address => "example.com", :port => 1234}
      
      transport.expects(:send_msg).with("www.example.com", 5432, "notify", input_node_hash).returns(true)
      
      rnode = RemoteNode.new(remote_node_hash)
      assert_equal true,
                   rnode.notify(Node.new(input_node_hash))
    end
    
    def test_closest_preceding_node
      transport = mock()
      result_node_hash = {:id => 5, :address => "www.example.com", :port => 5432}
      input_node_hash = {:id => 1, :address => "example.com", :port => 1234, :transport => transport}
      
      transport.expects(:send_msg).with("example.com", 1234, "closest_preceding_node", 1).returns(result_node_hash)
      rnode = RemoteNode.new(input_node_hash)
      assert_equal RemoteNode.new(result_node_hash), rnode.closest_preceding_node(ChordId.new(1))
    end
    
    def test_ping
      transport = mock()
      transport.expects(:send_msg).with(nil, nil, "ping").returns(true)
      
      rnode = RemoteNode.new(:transport => transport)
      assert rnode.ping
    end
    
    def test_predecessor
      result_node_hash = {:id => 5, :address => "www.example.com", :port => 5432}
      transport = mock()
      transport.expects(:send_msg).with(nil, nil, "predecessor").returns(result_node_hash)
      
      rnode = RemoteNode.new(:transport => transport)
      assert_equal RemoteNode.new(result_node_hash), rnode.predecessor
    end
    
    def test_predecessor_nil
      transport = mock()
      transport.expects(:send_msg).with(nil, nil, "predecessor").returns(nil)
      
      rnode = RemoteNode.new(:transport => transport)
      assert_nil rnode.predecessor
    end
  end
end

