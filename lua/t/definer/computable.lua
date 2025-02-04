local t = t or require 't'
local call = t.call
return function(self, o, key)
  if type(o)=='nil' or (type(o)=='table' and not next(o)) or type(key)=='nil' then return nil end
  return call(rawget(o, key), self)
  end