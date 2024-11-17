local t=t or require "t"
local is=t.is
return function(x) return is.def(x) and not is.defroot(x) end