#!/usr/bin/env ruby
require 'rake'
require 'open3'

## Define standard options
metadata_filename = "/Users/zvb1/.pandoc/defaults/userinfo.yaml"

hash = {
    "syllabus_html" 	=>   ["-d defaults -d syllabus-html --self-contained", "html"],
    "syllabus_pdf"  	=>   ["-d defaults -d syllabus-latex --pdf-engine=xelatex --quiet", "pdf"],
    "UC_letterhead_pdf"	=>   ["-d defaults -d UC-letterhead-latex --pdf-engine=xelatex --quiet", "pdf"],
    "letter_pdf"	    =>   ["-d defaults -d letter --pdf-engine=xelatex --quiet", "pdf"],
}

## Match the hash key with the user input, to find the required set of options
options, extension = hash.fetch($*[0])

output_filename = File.join(File.dirname($*[1]), File.basename($*[1])).ext(extension)

## Construct command

command = "pandoc --metadata-file=\"#{metadata_filename}\" #{options}  --output \"#{output_filename}\" \"#{$*[1]}\""

## Run command
puts command

output = ""
error = ""
status = 0
Open3.popen3(command) do |stdin, stdout, stderr, thread|
    output << stdout.read
    error << stderr.read
    status = thread.value.exitstatus
end

## Parse output
if status==0
	puts output
	system %{open "#{output_filename}"}
else
    puts error
    exit 1
end
