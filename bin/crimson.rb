#!/usr/bin/env ruby

# bin/crimson

command, *args = ARGV

if command.nil?
    puts "Usage: crimson <command> [args]"
    exit 1
end

path_to_command = File.expand_path("../crimson-#{command}", __FILE__)
if !File.exist? path_to_command
    puts "Unknown command: #{command}"
    exit 1
end

exec path_to_command, *args
