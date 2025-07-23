# Bundler::Browse

An interactive Bundler plugin that allows you to browse gems in your Gemfile, view their details, open their repositories, and update them individually.

## Keyboard shortcuts**:
  - `↑/↓`: Navigate through gems
  - `h`: Open homepage
  - `Enter`: Open source repository
  - `u`: Update the selected gem (with confirmation)
  - `q`: Quit

## Installation

Install the plugin using Bundler:

```bash
bundle plugin install bundler-browse
```

## Usage

Once installed, simply run this in the directory where your Gemfile is located:

```bash
bundle browse
```

This will display an interactive list of all gems directly specified in your Gemfile. Navigate with arrow keys, and use the keyboard shortcuts to perform actions.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests.

To test the plugin locally:

```bash
bundle plugin uninstall bundler-browse
bundle plugin install bundler-browse --path .
bundle browse
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/tnagatomi/bundler-browse. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/tnagatomi/bundler-browse/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Bundler::Browse project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/tnagatomi/bundler-browse/blob/main/CODE_OF_CONDUCT.md).
