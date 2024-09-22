local meta=require "meta"
local mt=meta.mt
local is=meta.is
local _=is
return function(x) return type(x)=='table' and type(mt(x).__def)=='string' and type(x._)=='table' and (not is.factory(x)) end
