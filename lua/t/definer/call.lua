local xpcall = require "meta.fn.xpcall"
return function(f, ...) return xpcall(f, nil, ...) end