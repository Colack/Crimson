#!/usr/bin/env ruby

# bin/crimson-init

CRIMSON_DIRECTORY = ".crimson".freeze
OBJECTS_DIRECTORY = "#{CRIMSON_DIRECTORY}/objects".freeze
REFS_DIRECTORY = "#{CRIMSON_DIRECTORY}/refs".freeze

if Dir.exists? CRIMSON_DIRECTORY
    puts "Crimson repository already initialized"
    exit 1
end

def build_objects_directory
    Dir.mkdir OBJECTS_DIRECTORY
    Dir.mkdir "#{OBJECTS_DIRECTORY}/pack"
    Dir.mkdir "#{OBJECTS_DIRECTORY}/info"
end

def build_refs_directory
    Dir.mkdir REFS_DIRECTORY
    Dir.mkdir "#{REFS_DIRECTORY}/heads"
    Dir.mkdir "#{REFS_DIRECTORY}/tags"
end

def init_head
    File.open("#{CRIMSON_DIRECTORY}/HEAD", "w") do |file|
        file.write "ref: refs/heads/master\n"
    end
end

Dir.mkdir CRIMSON_DIRECTORY
build_objects_directory
build_refs_directory
init_head

puts "Initialized empty Crimson repository in #{Dir.pwd}/#{CRIMSON_DIRECTORY}"
