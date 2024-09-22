local meta = require "meta"
local t = t or require "t"
local is = t.is
local mt = meta.mt
local export = t.exporter
local getmetatable=debug and debug.getmetatable or getmetatable
local json=require "t.format.json"

local _=require "t.storage.mongo"
local oid=require "t.storage.mongo.oid"
local cache=meta.cache
local __storage = cache.storage
local storage=setmetatable({},{__index=function(_, self)
return __storage[self][tostring(self)] end })
local tables=table{'__computed', '__computable', '__imports', '__required', '__id', '__default'}:tohash()

return t.object({
__add=function(self, it)
  assert(is.def(self), ("__add: not is.def(self: %s)"):format(type(self)))
  it=self(it)
  if it then return storage[self] + it end
end,
__call=function(self, it)
  assert(is.def(self), ("__call: not is.def(self: %s)"):format(type(self)))
  if is.def(it) then return it end
  if type(it)=='string' then
    if is.json(it) then it=json.decode(it) else
      local id=self/it
      if id then return id end
    end
  end
  if is.complex(it) and mt(it).__export then it=export(it) end
  if is.atom(it) or is.imaginary(it) or type(it)=='userdata' then return end
  assert(type(it)=='table', ('t.definer: invalid type: await table, got %s'):format(type(it)))
  if is.bulk(it) then return t.array(it)*self end
  assert(type(getmetatable(it))=='nil', ('t.definer: invalid mt type: await nil, got %s'):format(type(getmetatable(it))))

  local rv=setmetatable({_={}}, getmetatable(self))

  local required=self.__required
  local default =self.__default
  for _,k in pairs(required) do
    rv[k]=default[k]
  end
  for k,v in pairs(it) do
    if type(k)=='string' then
      rv[k]=v
    end
  end
  return toboolean(rv) and rv or nil
end,
__concat=function(self, it)
  assert(is.def(self), "t.definer.__concat: not is.def(self)")
  if type(it)=='table' and is.empty(it) then it=nil end
  if it then it=self(it) end
  if it then
    for _,v in pairs(it) do
      assert(not is.bulk(v))
    end
    return storage[self] .. it
  end
end,
__div=function(self, it)
  assert(is.def(self), "t.definer.__div: not is.defroot(self)")
  if is.defitem(it) then return it/true end
  if is.json(it) then it=json.decode(it) end
  if type(it)=='nil' then return end
  if is.bulk(it) and #it>0 then
    it=t.array(it)
    local rv=t.array()
    for _,v in pairs(it) do rv[#rv+1]=self/v end
    return #rv>0 and rv or nil
  end
  if is.table(it) then return it end
  local ids=table({'_id'}) .. self.__id
  local idn, idx
  if is.defitem(self) and type(it)=='boolean' and self._ then
    for _,k in ipairs(ids) do
      idx=self[k]
      if idx then idn=k; break end
    end
    if idn and idx and it==false then return idn end
  elseif is.defroot(self) and type(it)=='string' then
    if is.oid(it) then idn,idx='_id',it else
    for _,k in ipairs(self.__id) do
      local item=self.__imports[k]
      if is.callable(item) then
        idx=item(it)
        if idx then idn=k; break end
      end
    end end
  end
  if idn and idx then return {[idn]=idx} end
end,
__eq=function(self, it)
  if type(self)=='nil' or type(it)=='nil' then return false end
  if not is.def(self) then
    if is.def(it) then
      return it==self
    end
    return false
  end
  local seen={}
  local fields = self.__imports
  for k,v in pairs(self) do
    seen[k]=true
    local field = fields[k]
    if is.callable(field) then
      if not is.eq(field(v), field(it[k])) then return false end
    else
      if not is.eq(v, it[k]) then return false end
    end
  end
  for k,_ in pairs(it) do if (not seen[k]) then return false end end
  return true
end,
__imports={_id=oid},
__mod=function(self, it)
  assert(is.def(self), "t.definer.__mod: not is.def(self)")
  it=type(it)=='string' and self/it or nil
  return (type(it)=='table' or type(it)=='nil') and storage[self]%it or 0
end,
__mul=function(self, it)
  assert(is.def(self), "t.definer.__mod: not is.def(self)")
  it=type(it)=='string' and self/it or nil
  return (type(it)=='table' or type(it)=='nil') and self(storage[self]*it) or nil
end,
__newindex=function(self, key, value)
  if is.defroot(self) then
    if is.bulk(key) then key=t.array(key) end
    if is.bulk(value) then value=t.array(value) end
    local st=storage[self]
    if type(key)=='string' then
      local query=self/key
      if query then st[query]=value end
    end
    if type(key)=='nil' or is.bulk(key) then st[key]=value end
    return
  end
  if is.defitem(self) then
    assert(self._, '_ not defined')
    local field=self.__imports[key]
    if type(value)=='nil' then
      self._[key]=nil
    else
      local new_value
      if is.callable(field) then
        new_value=field(value)
      else
        new_value=value
      end
      self._[key]=new_value
    end
  end
end,
__pairs=function(self) return pairs(self._ or {}) end,
__sub=function(self, it)
  assert(is.defroot(self), "__sub: not is.defroot(self)")
  it=self/it
  if it then return storage[self] - it end
end,
__toboolean=function(self)
  if not self._ then return false end
  local required = self.__required
  if type(required)=='nil' then return true end
  if type(required)~='table' then return false end
  for _,it in pairs(required) do if type(self[it])=='nil' then return false end end
  return true
end,
__tostring=function(self) return cache.type[self] or cache.type[getmetatable(self)] end,
__unm=function(self)
  if is.defroot(self) then return -storage[self] end
  if is.defitem(self) then return storage[self]-self end
end,
}):postindex(function(self, key)
  if is.mtname(key) then return mt(self)[key] or (tables[key] and {}) end
  if key=='_' then return rawget(self,key) end
  if is.defroot(self) then
    if is.table(key) then return self(storage[self]*key) end
    local query=self/key
    return query and self(storage[self][query])
  end
  if is.defitem(self) then
    if type(key)=='string' and #key>0 and self._ then
      return self._[key]
    end
  end
end):definer()
