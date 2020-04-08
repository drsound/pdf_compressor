#!/usr/bin/env ruby

MINIMUM_COMPRESSION_RATIO = 90

require 'shellwords'

if ARGV.size != 1
  puts "Usage: #{File.basename($0)} FILE"
  exit 1
end

if !File.file?(ARGV[0])
  puts "File \"#{ARGV[0]}\" does not exist!"
  exit 1
end

begin

  temp = `mktemp --tmpdir pdf_compressor.XXXXXXXXXX`
  if $?.exitstatus != 0
    puts 'Error creating temporary file!'
    exit 1
  end

  output = Shellwords.escape(temp)
  input = Shellwords.escape(ARGV[0])
  `gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/ebook -dNOPAUSE -dQUIET -dBATCH -sOutputFile=#{output} #{input}`
  if $?.exitstatus != 0
    puts 'Ghostscript error!'
    exit 1
  end

  input_size = File.size(ARGV[0])
  output_size = File.size(temp)

  if output_size == 0
    puts 'Ghostscript error!'
    exit 1
  end

  obtained_ratio = (100.0 * output_size / input_size).round

  if obtained_ratio > MINIMUM_COMPRESSION_RATIO
    puts "Can't get enough compression, keeping original version"
    exit 0
  end

  puts "New size: #{obtained_ratio}%"
  `cp #{output} #{input}`

ensure
  `rm #{output}`
end
