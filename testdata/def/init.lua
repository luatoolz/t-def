local t = t or require"t"
local pkg = ...
return require("meta").loader(pkg) ^ t.definer
