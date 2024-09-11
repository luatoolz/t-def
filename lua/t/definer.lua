local t = t or require "t"
local is = t.is
local mt = require "meta.mt"
local json=require "t.format.json"
--local bson=require "t.format.bson"

local inspect = require "inspect"
local no = require "meta.no"

return t.object({
__call=function(self, it)
  it=it or {}
  if type(it)=='string' then it=json.decode(it) end
  if type(it)~='table' then return nil end
  local fields = mt(self).__imports or {}
  for k,v in pairs(fields) do
    local q=it[k]
    if type(q)~='nil' and is.callable(v) then
      it[k]=no.assert(v(q))
    end
  end
  local required=mt(self).__required or {}
  local default =mt(self).__default or {}
  for _,k in pairs(required) do
    if type(it[k])=='nil' then it[k]=default[k] or fields[k]() end
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
__pairs=function(self) return next, self, nil end,
__toboolean=function(self) -- validate
  local required = mt(self).__required
  if type(required)=='nil' then return true end
  if type(required)~='table' then return false end
  for _,it in pairs(required) do
    if type(it)~='string' or it=='' or type(self[it])=='nil' then return false end
  end
  return true
end,
}):definer()
