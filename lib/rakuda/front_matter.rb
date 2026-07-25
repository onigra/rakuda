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

    def self.split_summary(body)
      parts = body.split("<!--more-->", 2)
      (parts.length == 2) ? [parts[0].strip, parts[1].strip] : [body.strip, ""]
    end
  end
end
