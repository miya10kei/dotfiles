#! /usr/bin/ruby

require 'jsonpath'
require 'json'

path = ARGV[0]
raw = STDIN.read

json_path = JsonPath.new(path)
parsed = json_path.on(raw)

puts JSON.pretty_generate(parsed)

