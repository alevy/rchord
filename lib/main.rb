#!/usr/bin/env ruby

require 'rchord/local_node'

include RChord

puts KEY_SIZE

pred = []

for i in 0..128
  n = LocalNode.new({:id => rand(2**KEY_SIZE)})
  puts "#{i}: #{n}, #{pred.first}"
  n.join(pred.first || n)
  pred << n
  n.start
end

STDOUT.sync = true

print ">> "
while id = gets
  if match = id.match(/^p ([0-9]+)/)
    cur =  pred[match[1].to_i]
    puts cur
    puts cur.successor
  else
    puts pred.first.find_successor(ChordId.new(eval(id))).to_s
  end
  print ">> "
end

