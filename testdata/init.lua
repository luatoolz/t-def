local pkg = ...
local meta = require("meta")
local rv =  meta.loader(pkg)
local _ = meta.is ^ 'testdata'
return rv
