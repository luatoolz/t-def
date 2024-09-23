local meta = assert(require "meta", "no: meta")
local t = assert(t or require "t", "t.def:no: t")
local mod = meta.module('testdata')
if mod.exists then
  local td = assert(require "testdata", "t.def:no: testdata")
  return require("t.storage.mongo") ^ td.def
end
