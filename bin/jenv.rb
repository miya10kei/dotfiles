#!/usr/bin/env ruby

require 'open3'

def main()
  if ARGV.size == 0 then
    puts "Error"
  end

  case ARGV[0]
  when 'ls' then ls
  when 'use' then use
  end

end

def ls()
  _, e, _ = Open3.capture3("/usr/libexec/java_home -V")
  e.split("\n").each_with_index do |v, i|
    puts v.split(",")[0].strip if i > 0
  end
end

def use()
  o, e, _ = Open3.capture3("/usr/libexec/java_home -v #{ARGV[1]}")
  if e then
    File.open("#{ENV['HOME']}/.java_version", "w") do |file|
      file.puts "export JAVA_HOME=\"#{o.strip}\""
      file.puts 'export PATH="$JAVA_HOME:$PATH"'
    end
    puts "version: #{o}"
  else
    puts e
  end
end

main
