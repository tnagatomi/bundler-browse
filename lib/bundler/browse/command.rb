# frozen_string_literal: true

require "bundler/plugin/api"
require_relative "ui"
require_relative "updater"

module Bundler
  module Browse
    class Command
      def exec(command_name, args)
        ui = UI.new
        updater = Updater.new
        
        direct_dependency_names = Bundler.definition.dependencies.map(&:name).to_set
        
        gems = Bundler.definition.specs.select do |spec|
          direct_dependency_names.include?(spec.name)
        end
        
        ui.run(gems, updater)
      rescue StandardError => e
        Bundler.ui.error "Error: #{e.message}"
        Bundler.ui.debug e.backtrace.join("\n")
        1
      end
    end
  end
end