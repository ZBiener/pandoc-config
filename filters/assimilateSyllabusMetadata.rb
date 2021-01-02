#!/usr/bin/env ruby
# This regularises date:, course-number:, time:, location:, and affiliation metadata fields
# into a standardised structure that is better parsed by scholar-html templates.
# VERSION: 1.0.0

require 'paru/filter'

Paru::Filter.run do
	stop! if metadata.key('subtitle')
	newSubtitle = nil
	subtitleArray = []
    newAuthor = []

	#============subtitle

	subtitleArray.push(metadata['course-number']) if metadata.key?('course-number')
	subtitleArray.push(metadata['date']) if metadata.key?('date')
	subtitleArray.push(metadata['time']) if metadata.key?('time')
	subtitleArray.push(metadata['location']) if metadata.key?('location')
	subtitleArray.push(metadata['office-hours']) if metadata.key?('office-hours')
	metadata['subtitle'] = subtitleArray.join(' · ') unless subtitleArray.empty?

	#============ name and affiliation

	newAuthor.push(metadata['author']) if metadata.key?('author')
	if metadata.key?('affiliation')
		newAuthor.push(metadata['affiliation']) 
	elsif metadata.key?('institute')
		newAuthor.push(metadata['affiliation']) 
	end
	metadata['author'] = newAuthor.join(' · ') unless newAuthor.empty?
	metadata['institute'] = nil

	#============Write our new fields
	metadata['subtitle'] = newSubtitle unless newSubtitle.nil?
	stop!
end
