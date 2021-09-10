local utils = require 'pandoc.utils'
local stringify = utils.stringify

function Meta(m)
  for k, v in pairs(m.author[1]) do
    if k == "name" then
      m.author = v
    end
    m[k] = v
  end

  return m
end