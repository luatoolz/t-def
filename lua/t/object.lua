local t=t or require "t"
local pkgn = ...
local pkg = t.pkg('t.definer')
local is, mt, to, export, checker, json, mongo, index =
  t.is, t.mt.mt, t.to,
  t.exporter,
  t.checker,
  t.format.json,
  t.storage.mongo,
  pkg.index

local storage, oid, query, unquery =
  mongo.cache,
  mongo.oid,
  mongo.query,
  mongo.unquery

--[[
  __compute -- auto compute
--]]

local tables=table{'__compute', '__computed', '__computable', '__imports', '__required', '__id', '__default', '__action', '__filter'}:hashed()
local ok = checker({table=true,['function']=true}, type)
local mtnil = checker({table={getmetatable,type,{['nil']=true}}}, type)

return setmetatable({},{
__add=function(self, it) if not storage[self] then return end
  if is.null(it) then return nil end
  pkgn:assert(is.def(self), '__add', 'not def (%s)' % type(it))
  it=self(it)
  if not is.bulk(it) then return storage[self]+it end
  if #it>0 then return storage[self]..it end
end,
__call=function(self, it)
  pkgn:assert(is.def(self), '__call', 'not def (%s)' % type(it))
  if is.def(it) then return it end
  if type(it)=='string' then
    if it=='' then return end
    if is.json(it) then it=json.decode(it)
  else
      local id=self/it
      if id then return id end
    end
  end
  if is.complex(it) and mt(it).__export then it=export(it) end
  if is.atom(it) or is.virtual(it) or is.userdata(it) then return end
  pkgn:assert(ok[it], 'invalid type: await table, got %s' % type(it))
  if is.bulk(it) then return t.array(it)*self end
  if type(it)=='function' then
    local rv=t.array()
    local el
    repeat el=it()
      if type(el)~='nil' then
        el=self(el)
        if type(el)~='nil' then table.insert(rv, el) end
        el=true
      end
    until type(el)=='nil'
    return rv
  end
  if mt(it).__jsontype then setmetatable(it, nil) end
  pkgn:assert(mtnil[it], 'invalid mt type: await nil, got', type(getmetatable(it)))

  local rv=setmetatable({_={}}, getmetatable(self))
  local required, default = self.__required, self.__default

  for _,k in pairs(required) do
    rv[k]=default[k]
  end
  for k,v in pairs(it) do
    if type(k)=='string' then
      rv[k]=v
    end
  end
  for _,k in ipairs(self.__compute) do local _ = rv[k] end
  return to.boolean(rv) and rv or nil
end,
__concat=function(self, it) if not storage[self] then return end
  pkgn:assert(is.def(self), '__concat', 'not def (%s)' % type(it))
  if is.empty(it) then return end
  it=self(it)
  if not is.bulk(it) then return storage[self]+it elseif is.bulk(it) and #it>0 then return storage[self]..it end
end,
__div=function(self, it)
  pkgn:assert(is.def(self), '__div', 'not def (%s)' % type(it))
  if is.defitem(it) then return it/true end
  if is.json(it) then it=json.decode(it) end
  if is.bulk(it) then
    it=t.array(it)*function(x) return self/x end
    return #it>0 and it or nil
  end
  if is.table(it) then return it end
  local ids=table({'_id'}) .. self.__id
  local idn, idx
  if is.defitem(self) then
    local y=it=='_id'
    for v in table.iter(self.__id) do if v==it then y=true end end
    if y then
      if type(it)=='string' and self[it] then
        return {[it]=self[it]}
      end
      return
    end
    if type(it)=='boolean' and self._ then
      for _,k in ipairs(ids) do
        idx=self[k]
        if idx then idn=k; break end
      end
      if idn and idx and it==false then return idn end
    end
  elseif is.defroot(self) and type(it)=='string' then
    if self.__filter and self.__filter[it] then return self.__filter[it] end
    if is.oid(it) then idn,idx='_id',oid(it) else
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
__index=index,
__le=function(a, b)
  pkgn:assert(is.similar(a, b), 'require similar objects')
  for it in table.iter(a) do if not b[it] then return false end end
  return true
end,
__lt=function(a, b)
  pkgn:assert(is.similar(a, b), 'require similar objects')
  return a <= b and not (b <= a)
end,
__mod=function(self, args) if not storage[self] then return end
  local it,_,_ = unquery(args)
  pkgn:assert(is.def(self), '__mod', 'not def (%s)' % type(it))
  it=(type(it)=='string' or type(it)=='boolean') and self/it or it
  return type(it)=='table' and storage[self]%it or 0
end,
__mul=function(self, args) if not storage[self] then return end
  if type(args)=='nil' then
    if is.defroot(self) then return -storage[self] end
    if is.defitem(self) then return storage[self]-self end
  end
  local it,opts,as = unquery(args)
  pkgn:assert(is.def(self), '__mul', 'not def (%s)' % type(it))
  it=type(it)=='string' and self/it or it
  if type(it)=='table' then
    local rv = storage[self]*query(it, opts, as)
    if as then
--      return table.iter(rv, self)
      return is.callable(rv)
        and function() return self(rv()) end
        or function() return nil end
    end
    return self(t.array(rv))
  end
end,
__newindex=function(self, key, value) if not storage[self] then return end
  if is.defroot(self) then
    if is.bulk(key) then key=t.array(key) end
    if is.bulk(value) then value=t.array(value) end
    local st=storage[self]
    if type(key)=='string' then
      local q=self/key
      if q then st[q]=value end
    end
    if type(key)=='nil' or is.bulk(key) then st[key]=value end
    if type(value)=='nil' then st[key]=value end
    return
  end
  if is.defitem(self) then
    pkgn:assert(self._, '_ not defined')
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
      if (not(type(new_value)=='table' and (not getmetatable(new_value)) and type(next(new_value))=='nil')) and (not(is.bulk(new_value) and #new_value==0 and type(next(new_value))=='nil')) then
        self._[key] = new_value
      end
    end
  end
end,
__pairs=function(self) return pairs(self._ or {}) end,
__sub=function(self, it) if not storage[self] then return end
  if is.null(it) then return end
  pkgn:assert(is.defroot(self), '__sub', 'not def (%s)' % type(it))
  it=self/it
  if it and storage[self] then return storage[self] - it end
end,
__toboolean=function(self)
  if is.defroot(self) then return true end
  if is.defitem(self) then
    if not self._ then return false end
    local required = self.__required
    if type(required)=='nil' then return true end
    if type(required)~='table' then return false end
    for _,it in pairs(required) do if type(self[it])=='nil' then return false end end
    return true
  end
end,
__tonumber=function(self) return to.number(storage[self]) end,
__tostring=function(self) return getmetatable(self).__name or 'object' end,
__unm=function(self) if not storage[self] then return end
  if is.defroot(self) then return -storage[self] end
  if is.defitem(self) then return storage[self]-self/true end
end,
__computable={
  ref=function(self) if is.defitem(self) then
    if not self._id then self._id=oid() end
    return mongo.ref(mt(self).__def, self._id)
  end end,
},
__preindex=function(self, key)
  if type(key)=='nil' then return nil end
  if is.mtname(key) then return mt(self)[key] or (tables[key] and {}) end
  if key=='_' then return rawget(self,key) end
  if is.defroot(self) then
    if key=='' then return self.__ end
  end
end,
__postindex=function(self, k)
  local key,options,as=unquery(k)
  if is.defroot(self) then
    if type(key)=='string' then
      if self.__action[key] then return self.__action[key] end
      if self.__filter[key] then key=self/key end
    end
    if is.table(key) then return self*query(key, options, as) end
    local q=self/key
    return q and self(storage[self][query(q, options, as)])
  end
  if is.defitem(self) then
    if type(key)=='string' and #key>0 and self._ then
      return self._[key]
    end
  end
end})