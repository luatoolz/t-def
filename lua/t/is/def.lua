local meta=require "meta"
local mt=meta.mt
local object=require "t.definer.index"
return function(x) return type(x)=='table' and rawequal(mt(x).__index, object) end