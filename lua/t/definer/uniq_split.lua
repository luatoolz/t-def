local t=t or require "t"
return function(it)
  if type(it)=='string' then it=it:split(' ') end
  if type(it)~='table' then it=nil end
  local rv=table(it):uniq()
  if type(next(rv))~='nil' then return setmetatable(rv, nil) end
end