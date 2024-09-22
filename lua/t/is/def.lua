local meta=require "meta"
local mt=meta.mt
return function(x) return type(x)=='table' and type(mt(x).__def)=='string' end