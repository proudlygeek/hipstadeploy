#!/usr/bin/ruby
# via http://stackoverflow.com/questions/1274605/ruby-search-file-text-for-a-pattern-and-replace-it-with-a-given-value

rssFolder = "./#{ARGV[0]}rss/*"
localURL = ARGV[1]
remoteURL = ARGV[2]

puts "Replacing '#{localURL}' with '#{remoteURL}' in #{rssFolder}"

files = Dir.glob(rssFolder)

files.each do |file_name|
  text = File.read(file_name)
  replace = text.gsub!(localURL, remoteURL)
  File.open(file_name, "w") { |file| file.puts replace }
end
