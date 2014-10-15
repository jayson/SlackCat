# Set up bundler and lib load path
require "rubygems"
require "bundler"
Bundler.setup
require "cinch"
require "cinch/exceptions"
require "json"
$LOAD_PATH.unshift File.join(File.expand_path(File.dirname(__FILE__)), "lib")
require "slack_bot"
