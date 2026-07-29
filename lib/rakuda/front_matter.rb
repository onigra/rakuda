# frozen_string_literal: true

require "front_matter_parser"
require "time"
require "date"

module Rakuda
  module FrontMatter
    YAML_LOADER = FrontMatterParser::Loader::Yaml.new(allowlist_classes: [Time, Date])
    PARSER = FrontMatterParser::Parser.new(:md, loader: YAML_LOADER)

    def self.parse_file(path)
      parse(File.read(path))
    end

    def self.parse(content)
      parsed = PARSER.call(content)
      [parsed.front_matter, parsed.content]
    end
  end
end
