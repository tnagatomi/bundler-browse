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
        @viewport_offset = 0
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

      def calculate_viewport_dimensions
        header_lines = 2  # "Gems in Gemfile:" + separator
        footer_lines = 9  # gem info (5) + separator (1) + controls (1) + separators (2)
        available_lines = TTY::Screen.height - header_lines - footer_lines
        [available_lines, 5].max  # Minimum 5 lines for gem list
      end

      def update_viewport_offset(available_lines)
        if @selected_index < @viewport_offset
          @viewport_offset = @selected_index
        elsif @selected_index >= @viewport_offset + available_lines
          @viewport_offset = @selected_index - available_lines + 1
        end
      end

      def render_header
        puts "Gems in Gemfile:"
        puts "─" * TTY::Screen.width
      end

      def render_gem_list
        available_lines = calculate_viewport_dimensions
        update_viewport_offset(available_lines)

        visible_gems = @gems[@viewport_offset, available_lines]
        visible_gems.each_with_index do |gem, index|
          actual_index = @viewport_offset + index
          prefix = actual_index == @selected_index ? "▶ " : "  "
          puts "#{prefix}#{gem.name} (#{gem.version})"
        end

        # Fill remaining lines
        (available_lines - visible_gems.size).times { puts }

        render_scroll_indicator if @gems.size > available_lines
      end

      def render_scroll_indicator
        indicator = " [#{@selected_index + 1}/#{@gems.size}]"
        print @cursor.save
        print @cursor.move_to(TTY::Screen.width - indicator.length, 2)
        print indicator
        print @cursor.restore
      end

      def render_footer
        puts "─" * TTY::Screen.width
        render_gem_info(@gems[@selected_index]) if @selected_gem = @gems[@selected_index]
        puts "─" * TTY::Screen.width
        puts "[↑↓/jk] Navigate  [h] Homepage  [Enter] Source  [u] Update  [q] Quit"
      end

      def render_ui
        print @cursor.move_to(0, 0)
        print @cursor.clear_screen_down

        render_header
        render_gem_list
        render_footer
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
        when "\e[A", "k"  # Up arrow or k
          @selected_index = (@selected_index - 1) % @gems.size
        when "\e[B", "j"  # Down arrow or j
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
