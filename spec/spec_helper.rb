$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'lanyard'
require 'lanyard/security'
require 'lanyard/lanyard_cmd'

require "codeclimate-test-reporter"
CodeClimate::TestReporter.start
