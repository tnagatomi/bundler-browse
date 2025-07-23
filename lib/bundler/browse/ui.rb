# frozen_string_literal: true

require "tty-cursor"
require "tty-screen"
require "launchy"
require "io/console"

module Bundler
  module Browse
    class UI
      def initialize
        @cursor = TTY::Cursor
        @selected_index = 0
        @gems = []
      end

      def run(gems, updater)
        @gems = gems
        @updater = updater

        print @cursor.clear_screen
        print @cursor.hide

        begin
          loop do
            render_ui
            handle_input
          end
        ensure
          print @cursor.show
        end
      end

      private

      def render_ui
        print @cursor.move_to(0, 0)
        print @cursor.clear_screen_down

        puts "Gems in Gemfile:"
        puts "─" * TTY::Screen.width

        # Render gem list
        @gems.each_with_index do |gem, index|
          if index == @selected_index
            print "▶ "
          else
            print "  "
          end
          puts "#{gem.name} (#{gem.version})"
        end

        puts "─" * TTY::Screen.width

        render_gem_info(@selected_gem) if @selected_gem = @gems[@selected_index]

        puts "─" * TTY::Screen.width
        puts "[↑↓] Navigate  [h] Homepage  [Enter] Source  [u] Update  [q] Quit"
      end

      def render_gem_info(gem)
        metadata = gem.metadata || {}

        puts "Current Selection:"
        puts "  Name: #{gem.name}"
        puts "  Version: #{gem.version}"
        puts "  Homepage: #{gem.homepage || "N/A"}"
        puts "  Source: #{metadata["source_code_uri"] || extract_source_uri(gem) || "N/A"}"
      end

      def extract_source_uri(gem)
        return unless gem.homepage&.match?(%r{https?://github\.com/[\w-]+/[\w-]+})

        gem.homepage
      end

      def handle_input
        case read_key
        when "\e[A"
          @selected_index = (@selected_index - 1) % @gems.size
        when "\e[B"
          @selected_index = (@selected_index + 1) % @gems.size
        when "\r" # Enter
          open_source(@gems[@selected_index])
        when "h"
          open_homepage(@gems[@selected_index])
        when "u"
          update_gem(@gems[@selected_index])
        when "q", "\u0003" # q or Ctrl+C
          print @cursor.clear_screen
          print @cursor.move_to(0, 0)
          print @cursor.show
          exit
        end
      end

      def read_key
        $stdin.raw do |io|
          input = io.getc
          if input == "\e"
            begin
              input << io.read_nonblock(2)
            rescue StandardError
              nil
            end
          end
          input
        end
      end

      def open_homepage(gem)
        if gem.homepage
          Launchy.open(gem.homepage)
          message = "Opening homepage: #{gem.homepage}"
        else
          message = "No homepage available for #{gem.name}"
        end

        show_message(message)
      end

      def open_source(gem)
        metadata = gem.metadata || {}
        source_uri = metadata["source_code_uri"] || extract_source_uri(gem)

        if source_uri
          Launchy.open(source_uri)
          message = "Opening source: #{source_uri}"
        else
          message = "No source code URI available for #{gem.name}"
        end

        show_message(message)
      end

      def update_gem(gem)
        print @cursor.show
        @updater.update_gem(gem.name)
        print @cursor.hide
      end

      def show_message(message)
        print @cursor.save
        print @cursor.move_to(0, TTY::Screen.height - 2)
        print @cursor.clear_line
        print message
        sleep 2
        print @cursor.restore
      end
    end
  end
end
