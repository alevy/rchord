require 'json'

module RChord
  module Serializer
    class JSON
      
      def load(arg)
        JSON::load(arg)
      end
      
      def dump(arg)
        JSON::dump(arg)
      end
      
    end
  end
end
