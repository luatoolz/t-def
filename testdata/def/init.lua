local t = t or require "t"
local meta = require "meta"
local pkg = (...)
return meta.loader(pkg) ^ t.definer
