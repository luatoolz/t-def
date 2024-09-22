local meta=require "meta"
local mt=meta.mt
local is=meta.is
return function(x) return type(x)=='table' and type(mt(x).__def)=='string' and is.factory(x) end