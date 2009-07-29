#!/usr/bin/ruby
require 'open-uri'

url = "http://www.dns-sd.org/ServiceTypes.html"

data = nil
open(url) { |f| data = f.read() }

if data.nil?
    puts "Can't read url #{url}"
end

lines = data.split(/[\r\n]+/)

for line in lines
    match = line.match(/^<b>(.*?)<\/b>\s+(.*)/)
    if match
        puts "                       @\"#{match[2].gsub(/"/,"\\\"")}\", @\"_#{match[1]}._tcp.\","
    end
end