local t = t or require "t"
local is = t.is
local to = t.to
return function(v)
  if type(v) == 'string' then
    return string.matcher(v == '' and '.+' or v), nil
  elseif type(v) == 'boolean' then
    return to.boolean, v
  elseif type(v) == 'number' then
    if v == 0 then
      return to.number, nil
    elseif is.integer(v) then
      return to.integer, v
    else
      return t.number, v
    end
  elseif is.callable(v) then
    return v
  end
end