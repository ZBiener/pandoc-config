#!/usr/bin/env ruby
require 'rake'
require 'open3'
require 'yaml'

puts "NEW RUN"
# Usage: 
# call_pandoc.rb format_option filename.md
# OR
# call_pandoc.rb filename.md
#
# if no format_options is specified on the commandline, parse the metadata of the 
# input file is parsed to determine the format field. Format_option specified on the command line
# supersedes format_option specified in the file metadata

## Define standard options
metadata_filename = "/Users/zvb1/.local/share/pandoc/defaults/user-metadata.yaml"
local_defaults_filename = 'local-defaults'
scrivener_output_directory="/Users/zvb1/Temp/LaTeX_Compile"
options = "#{$*[0]}"
filename = "#{$*[1]}"


puts "#{$*}"

if options == "scrivener"
    filename = "#{scrivener_output_directory}/#{filename}"
end 

#puts " options: #{options} \n"
#puts " input filename: #{filename} \n"

base_config_pdf=' --pdf-engine=/Library/TeX/texbin/xelatex --quiet '

hash = {
    "handout"    	=>      [base_config_pdf + "-d pandoc-scholar-html -d course-handout-html --self-contained", "html"],
    "syllabus"  	=>      [base_config_pdf + "-d formal-syllabus-latex", "pdf"],
    "UC_letterhead"	=>      [base_config_pdf + "-d UC-letterhead-latex", "pdf"],
    "letter"	    =>      [base_config_pdf + "-d letter", "pdf"],
    "old_fashioned"	=>      [base_config_pdf + "-d old-fashioned-article", "pdf"],
    "beamer" =>             [base_config_pdf + "-d beamer", "pdf"],
    "scholar_html"  =>      [base_config_pdf + "-d pandoc-scholar-html --self-contained", "html"],
    "simple_tex" =>         [base_config_pdf + "-d simple", "tex" ],
    "syllabus_tex"      =>  ["-d formal-syllabus-latex", "tex"],
    "UC_letterhead_tex" =>  ["-d UC-letterhead-latex", "tex"],
    "letter_tex"        =>  ["-d letter", "tex"],
    "old_fashioned_tex" =>  ["-d old-fashioned-article", "tex"],
    "scholar_html_tex"  =>    ["-d local-defaults -d pandoc-scholar-html --self-contained", "html"],
    "simple" =>   ["-d local-defaults -d simple --pdf-engine=/Library/TeX/texbin/xelatex", "pdf" ],
    "bib_list" =>   ["-d local-defaults -d bib_list --pdf-engine=/Library/TeX/texbin/xelatex", "pdf" ],
    "scrivener" => ["read_file_metadata"],
    "metadata" => ["read_file_metadata"],

}

## Match the hash key with the user input, to find the required set of options
## if no format_option is provided, parse the metadata of the input file to determine the format field, 
## and match with the hash above. 
## the default is only useful when running from the commandline. Running from Scrivener will automatically
## trigger reading the format from the metadata

options, extension = hash.fetch(options) {"No proper format specified"}
if options == "No proper format specified"
    puts "No proper format specified on the command line, or check for format spelling error"
    return
end

if options=="read_file_metadata"
    metadata = YAML.load_file(filename)
    puts metadata.inspect
    format = metadata.fetch("format") {"No_format_specified"} #curly brackets is the default, if not match is found
    if format == "No_format_specified"
        puts "No format specified in metadata or command line"
        return
    else
        options, extension = hash.fetch(format) {"No proper format specified"}
        if options == "No proper format specified"
            puts "No proper format specified in metadata or command line, check for spelling errors"
            return
        end
    end
end


base_directory = File.dirname(filename)
output_filename = File.join(base_directory, File.basename(filename)).ext(extension)

## Construct command

command = "pandoc -d local-defaults --metadata-file=\"#{metadata_filename}\"  #{options} --output \"#{output_filename}\" \"#{filename}\""

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
	if extension!="tex"
        system %{open "#{output_filename}"}
    end
else
    puts error
    exit 1
end
