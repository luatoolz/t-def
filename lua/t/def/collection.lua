local t=t or require "t"
return setmetatable({}, {
  __filter = {
    all = {},
    empty = {empty=1},
    filled = {empty=0},
  },
  __action = function(self)
    local it,tab,k,v=pairs(t.storage.mongo)
    return function() if k then k,v=it(tab, k); return v end end
  end,
})