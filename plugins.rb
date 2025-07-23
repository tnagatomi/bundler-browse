# frozen_string_literal: true

require "bundler/browse"
require "bundler/browse/command"

Bundler::Plugin::API.command "browse", Bundler::Browse::Command
