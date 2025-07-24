# frozen_string_literal: true

require_relative "lib/bundler/browse/version"

Gem::Specification.new do |spec|
  spec.name = "bundler-browse"
  spec.version = Bundler::Browse::VERSION
  spec.authors = ["Takayuki Nagatomi"]
  spec.email = ["tnagatomi@okweird.net"]

  spec.summary = "Browse and update gems interactively from your Gemfile"
  spec.description = "A bundler plugin that provides an interactive CLI to browse gems in your Gemfile, view their details, open their repositories, and update them individually."
  spec.homepage = "https://github.com/tnagatomi/bundler-browse"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/tnagatomi/bundler-browse"
  spec.metadata["changelog_uri"] = "https://github.com/tnagatomi/bundler-browse/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Runtime dependencies
  spec.add_dependency "launchy", "~> 3.1"
  spec.add_dependency "tty-cursor", "~> 0.7"
  spec.add_dependency "tty-prompt", "~> 0.23"
  spec.add_dependency "tty-screen", "~> 0.8"
end
