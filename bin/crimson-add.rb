#!/usr/bin/env ruby

# bin/crimson-add

$LOAD_PATH << File.expand_path("../../lib", __FILE__)
require "digest"
require "zlib"
require "crimson/object"

CRIMSON_DIRECTORY = ".crimson".freeze
INDEX_PATH = "#{CRIMSON_DIRECTORY}/index".freeze

if !Dir.exists? CRIMSON_DIRECTORY
    puts "Not a Crimson repository"
    exit 1
end

path = ARGV.first

if path.nil?
    $stderr.puts "Usage: crimson-add <path>"
    exit 1
end

file_contents = File.read(path)
sha = Digest::SHA1.hexdigest file_contents
blob = Zlib::Deflate.deflate file_contents
object = Crimson::Object.new("blob", blob)

object.write do |file|
    file.print blob
end

File.open(INDEX_PATH, "a") do |file|
    file.puts "#{sha} #{path}"
end
