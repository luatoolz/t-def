local call = require "t.definer.call"
return function(self, t, key)
  if type(t)=='nil' or (type(t)=='table' and not next(t)) or type(key)=='nil' then return nil end
  return call(rawget(t, key), self)
  end