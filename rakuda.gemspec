# frozen_string_literal: true

require_relative "lib/rakuda/version"

Gem::Specification.new do |spec|
  spec.name = "rakuda"
  spec.version = Rakuda::VERSION
  spec.authors = ["onigra"]
  spec.email = ["3280467rec@gmail.com"]

  spec.summary = "Minimal static site generator"
  spec.description = "Minimal static site generator for onigra.github.io"
  spec.homepage = "https://github.com/onigra/rakuda"
  spec.required_ruby_version = ">= 3.2.0"
  spec.metadata["allowed_push_host"] = "TODO: Set to your gem server 'https://example.com'"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage

  spec.metadata["rubygems_mfa_required"] = "true"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ Gemfile .gitignore test/ .github/ .standard.yml docs/ Rakefile .mise.toml])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "front_matter_parser", "~> 1.0"
  spec.add_runtime_dependency "kramdown", "~> 2.4"
  spec.add_runtime_dependency "kramdown-parser-gfm", "~> 1.1"
  spec.add_runtime_dependency "rack", "~> 3.0"
  spec.add_development_dependency "test-unit"
end
