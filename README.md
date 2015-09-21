# Lanyard

[![Gem Version](https://img.shields.io/gem/v/lanyard.svg)](http://badge.fury.io/rb/lanyard)
[![Build Status](https://travis-ci.org/wooga/lanyard.svg?branch=master)](https://travis-ci.org/wooga/lanyard)
[![Code Climate](https://codeclimate.com/github/wooga/lanyard/badges/gpa.svg)](https://codeclimate.com/github/wooga/lanyard)
[![Test Coverage](https://codeclimate.com/github/wooga/lanyard/badges/coverage.svg)](https://codeclimate.com/github/wooga/lanyard/coverage)
[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/wooga/lanyard/master/LICENSE.txt)

Lanyar is a little gem that helps to work with OSX keychains
It includes a simple wrapper for `security` and is able to add/remove custom keychains to the keychain lookip list with one command.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'lanyard'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install lanyard

## Usage

### Commandline tool
```
Usage:
  lanyard use-keychain [(-t=Time | --lock-timeout=Time)] (<keychain> <password>)...
  lanyard unuse-keychain <keychain>...
  lanyard (-h | --help)
```

### Rake
```ruby
require 'rake/lanyard_task'

lanyard = Rake::LanyardTask.new

# this will add the tasks :unlock and :reset
# By default the task will try to use a keychain called
# build.keychain located in the rake root.
```

```ruby
require 'rake/lanyard_task'

lanyard = Rake::LanyardTask.new { |t|
	t.namespace_name = :keychain
	t.keychain_path = "path/to/keychain-copy.keychain"
	t.keychain_password = "keychain password"
	t.copy_keychain_from "path/to/keychain.keychain"
}

# this will add the tasks :unlock and :reset in the namespace :keychain
# With the `copy_keychain_from` method you can configure that your build works with 
# a copy of a keychain instead the original file.
# This option will add a filetask along with the other tasks to make sure that the 
# keychain is available and up to date.
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake rspec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
