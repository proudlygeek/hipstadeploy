#!/usr/bin/ruby
# via http://stackoverflow.com/questions/1274605/ruby-search-file-text-for-a-pattern-and-replace-it-with-a-given-value

outputFolder = "./#{ARGV[0]}"
localURL = ARGV[1]
remoteURL = ARGV[2]

files = Dir.glob("#{outputFolder}rss/*") << Dir.glob("#{outputFolder}rss*") << Dir.glob("#{outputFolder}feed/*") << Dir.glob("#{outputFolder}feed*")

files.each do |file_name|
	if file_name.kind_of?(String)
		puts file_name
		text = File.read(file_name)
		replace = text.gsub!(localURL, remoteURL)
		File.open(file_name, "w") { |file| file.puts replace }
	end
end
