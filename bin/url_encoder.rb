#! /usr/bin/env ruby

require 'uri'
require 'cgi'

if ARGV.length <= 1 || !["-d", "-e"].include?(ARGV[0]) then
  puts "ruby #{$0} [-d|-e] $text"
  exit(-1)
end

puts ARGV[0] === "-e" ? CGI.escape(ARGV[1]) : CGI.unescape(ARGV[1])
