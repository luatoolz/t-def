local t = t or require "t"
--local meta = require "meta"
local is = t.is
--require"t.is"
local mt = require "meta.mt"
local json=require "t.format.json"
--local inspect = require 'inspect'

return t.object({
__call=function(self, it)
  it=it or {}
  if type(it)=='string' then it=json.decode(it) end
  if type(it)~='table' then return nil end
  local fields = mt(self).__imports or {}
  for k,v in pairs(fields) do
    local q=it[k]
    if type(q)~='nil' and is.callable(v) then it[k]=v(q) end
  end
  setmetatable(it, getmetatable(self))
  return toboolean(it) and it or nil
end,
__mod=function(self, it) -- build query
  local id = mt(self).__id
  if not id then return nil end
-- TODO: use every field
  return it and {[(id or {})[1]]=it} or nil
end,
__toboolean=function(self) -- validate
  local required = mt(self).__required
  if not required then return true end
  for _,it in pairs(required) do
    if not self[it] then return false end
  end
  return true
end,
--__toJSON=function(self)  end,
}):definer()
