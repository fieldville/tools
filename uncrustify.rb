#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
base_path = ENV['PWD']

puts "running uncrustify for xcode project path: #{base_path}"

if base_path != nil
  paths = `find "#{base_path}" -name "*.m" -o -name "*.h" -o -name "*.mm" -o -name "*.c"`
  if paths.kind_of?(String) then
    paths = paths.split(/\r?\n/).map {|line| line.chomp}
  end
  paths = paths.collect do |path|
    path.gsub(/(^[^\n]+?)(\n)/, '"\\1"')
  end
  paths = paths.join(" ")
  result = `/usr/local/bin/uncrustify -c ~/.dotfiles/.uncrustify.cfg --no-backup #{paths}`;
  puts result
else
  puts "Invalid base path..."
end

