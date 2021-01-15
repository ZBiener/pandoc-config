#!/usr/bin/env ruby
require 'rake'
require 'open3'

## Define standard options
metadata_filename = "/Users/zvb1/.pandoc/defaults/user-metadata.yaml"
local_defaults_filename = 'local-defaults'

hash = {
    "handout"    	=>   ["-d local-defaults -d pandoc-scholar-html -d course-handout-html --self-contained", "html"],
    "syllabus"  	=>   ["-d local-defaults -d formal-syllabus-latex --pdf-engine=xelatex --quiet", "pdf"],
    "UC_letterhead"	=>   ["-d local-defaults -d UC-letterhead-latex --pdf-engine=xelatex --quiet", "pdf"],
    "letter"	    =>   ["-d local-defaults -d letter --pdf-engine=xelatex --quiet", "pdf"],
    "old_fashioned"	=>   ["-d local-defaults -d old-fashioned-article --pdf-engine=xelatex --quiet", "pdf"],
    "reveal"        =>   ["-d local-defaults -d reveal-js", "html"],
    "scholar_html"  =>    ["-d local-defaults -d pandoc-scholar-html --self-contained", "html"],
}

## Match the hash key with the user input, to find the required set of options
options, extension = hash.fetch($*[0])
base_directory = File.dirname($*[1])
output_filename = File.join(base_directory, File.basename($*[1])).ext(extension)

## Construct command

command = "pandoc --metadata-file=\"#{metadata_filename}\" #{options} --output \"#{output_filename}\" \"#{$*[1]}\""

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
