# bundler-browse

This is a Bundler plugin that provides an interactive CLI to browse gems in your Gemfile, view their details, open their repositories, and update them individually.

## Architecture Overview

The plugin consists of three main components:

1. **Command** (`lib/bundler/browse/command.rb`): Entry point that filters direct dependencies from Gemfile
2. **UI** (`lib/bundler/browse/ui.rb`): Interactive terminal UI with real-time gem selection display
3. **Updater** (`lib/bundler/browse/updater.rb`): Handles individual gem updates with confirmation

## Key Design Decisions

- **Direct Dependencies Only**: Filters to show only gems explicitly declared in Gemfile, not transitive dependencies
- **Real-time Display**: Shows gem information inline as you navigate, rather than requiring separate screens
- **Keyboard Navigation**: Uses arrow keys for navigation and single-key shortcuts for actions
- **Terminal Control**: Uses tty-cursor and tty-screen for proper terminal manipulation without relying on tty-prompt's limitations

## Implementation Notes

- Uses `Bundler.definition.dependencies` to get direct dependencies
- Filters specs using a Set for efficient lookup
- Handles terminal cleanup properly on exit (clears screen, shows cursor)
- Uses Open3 for gem updates to show real-time output from `bundle update`

## Testing

When running tests, ensure the plugin is properly installed:
```bash
bundle plugin uninstall bundler-browse
bundle plugin install bundler-browse --path .
```
