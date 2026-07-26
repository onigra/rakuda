# frozen_string_literal: true

module Rakuda
  module Generators
    class Robots
      def initialize(config:)
        @config = config
      end

      def generate
        "User-agent: *"
      end
    end
  end
end
