local utils = require 'pandoc.utils'
local stringify = utils.stringify

course_metadata = {
    "course_number",
    "term",
    "time",
    "room",
    "office_hours"
}

function Meta(m)
  course_details = {} 
  for i, metadata_name in ipairs(course_metadata) do
    if (m[metadata_name] ~= nil) and (stringify(m[metadata_name]) ~= "") then
      table.insert(course_details, m[metadata_name]) 
    end
  end
  m.course_details = course_details
  return m
end