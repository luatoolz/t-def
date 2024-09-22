local t = t or require('t')
local meta = require "meta"
local mod = meta.module('testdata')
if mod.exists then
  local td = assert(require "testdata", "no: testdata")
  return assert(t.storage.mongo, "no: t.storage.mongo") ^ assert(td.def, "no: td.def")
end
