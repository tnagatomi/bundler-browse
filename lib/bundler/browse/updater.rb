# frozen_string_literal: true

require "open3"
require "tty-prompt"
require "io/console"

module Bundler
  module Browse
    class Updater
      def initialize
        @prompt = TTY::Prompt.new
      end

      def update_gem(gem_name)
        puts "\n"

        confirmed = @prompt.yes?("Update #{gem_name}?")

        return unless confirmed

        puts "\nUpdating #{gem_name}..."

        command = "bundle update #{gem_name}"

        success = false
        Open3.popen2e(command) do |stdin, stdout_stderr, wait_thread|
          stdout_stderr.each_line do |line|
            puts line
          end
          success = wait_thread.value.success?
        end

        if success
          puts "\nSuccessfully updated #{gem_name}"
        else
          puts "\nFailed to update #{gem_name}"
        end

        puts "\nPress any key to continue..."
        $stdin.getch
      rescue StandardError => e
        puts "\nError updating #{gem_name}: #{e.message}"
        puts "\nPress any key to continue..."
        $stdin.getch
      end
    end
  end
end
