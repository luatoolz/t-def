local pkg = ...
local meta = require("meta")
local rv =  meta.loader(pkg)
_ = meta.is ^ 'testdata'
return rv