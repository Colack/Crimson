#!/usr/bin/env ruby

$LOAD_PATH << File.expand_path("../../lib", __FILE__)
require "digest"
require "time"
require "crimson/object"

CRIMSON_DIRECTORY = "#{Dir.pwd}/.crimson".freeze
INDEX_PATH = "#{Crimson_DIRECTORY}/index"
COMMIT_MESSAGE_TEMPLATE = <<-TXT
# Title
#
# Body
TXT

def index_files
  File.open(INDEX_PATH).each_line
end

def index_tree
  index_files.each_with_object({}) do |line, obj|
    sha, _, path = line.split
    segments = path.split("/")
    segments.reduce(obj) do |o, s|
      if s == segments.last
        o[segments.last] = sha
        o
      else
        o[s] ||= {}
        o[s]
      end
    end
  end
end

def build_tree(name, tree)
  sha = Digest::SHA1.hexdigest(Time.now.iso8601 + name)
  object = Crimson::Object.new(sha)

  object.write do |file|
    tree.each do |key, value|
      if value.is_a? Hash
        dir_sha = build_tree(key, value)
        file.puts "tree #{dir_sha} #{key}"
      else
        file.puts "blob #{value} #{key}"
      end
    end
  end

  sha
end

def build_commit(tree:)
  commit_message_path = "#{Crimson_DIRECTORY}/COMMIT_EDITMSG"

  `echo "#{COMMIT_MESSAGE_TEMPLATE}" > #{commit_message_path}`
  `$VISUAL #{commit_message_path} >/dev/tty`

  message = File.read commit_message_path
  committer = "user"
  sha = Digest::SHA1.hexdigest(Time.now.iso8601 + committer)
  object = Crimson::Object.new(sha)

  object.write do |file|
    file.puts "tree #{tree}"
    file.puts "author #{committer}"
    file.puts
    file.puts message
  end

  sha
end

def update_ref(commit_sha:)
  current_branch = File.read("#{Crimson_DIRECTORY}/HEAD").strip.split.last

  File.open("#{Crimson_DIRECTORY}/#{current_branch}", "w") do |file|
    file.print commit_sha
  end
end

def clear_index
  File.truncate INDEX_PATH, 0
end

if index_files.count == 0
  $stderr.puts "Nothing to commit"
  exit 1
end

root_sha = build_tree("root", index_tree)
commit_sha = build_commit(tree: root_sha)
update_ref(commit_sha: commit_sha)
clear_index
