#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
base_path = ENV['PWD']
base_path ||= ENV['XcodeProjectPath'] + "/.."

config_path = "#{base_path}/.uncrustifyconfig"
config_path = "#{ENV['HOME']}/.uncrustify/uncrustify.cfg" if !File.exist?(config_path)

puts "running uncrustify for xcode project path: #{base_path}"
puts "                                   config: #{config_path}"

if base_path != nil
  paths = `find "#{base_path}" -name "*.m" -o -name "*.h" -o -name "*.mm" -o -name "*.c" | grep -vwE 'lib|libs'`
  if paths.kind_of?(String) then
    paths = paths.split(/\r?\n/).map {|line| line.chomp}
  end
  paths = paths.collect do |path|
    path.gsub(/(^[^\n]+?)(\n)/, '"\\1"')
  end
  paths = paths.join(" ")
  result = `/usr/local/bin/uncrustify -c "#{config_path}" --no-backup #{paths}`;
  puts result
else
  puts "Invalid base path..."
end

