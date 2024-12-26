local t=require "t"
local pkg=...
local is=t.is
local iter=table.iter
local mongo=t.storage.mongo
return setmetatable({
  name='[%w%/%._-]+$',
}, {
  __id={'name'},
  __required={'name'},
  __filter = {
    all = {},
  },
  __action={
    list=function(self) return iter(t.def) end,
		test=function(self) return 'action' end,
    actions=function(self)
      if is.defitem(self) then return self:actions() end
      local rv={}
      for name in iter(t.def) do
        rv[name] = self({name=name}):actions()
      end
      return rv
    end,
    filters=function(self)
      if is.defitem(self) then return self:filters() end
      local rv={}
      for name in iter(t.def) do
        rv[name] = self({name=name}):filters()
      end
      return rv
    end,
    default=function(self)
      local rv={}
      for name in iter(t.def) do
        if name ~= 'collection' then
          rv[name]=self({name=name}):stat()
        end
      end
      return rv
    end,
    collections = function(self)
      local rv={}
      if mongo then for k,_ in pairs(mongo) do table.insert(rv, k) end end
      return rv
    end,
    args = function(self)
      return t.nginx.auto.options()
    end,
  },
	test=function(self) return 'method' end,
	actions=function(self) if is.defitem(self) then
	    local d=t.def[self.name]
      return d and setmetatable(t.array(table.keys(d.__action)),nil)
  end end,
  filters=function(self) if is.defitem(self) then
    local d=t.def[self.name]
    return d and setmetatable(t.array(table.keys(d.__filter)),nil)
  end end,
	count=function(self, filter) if is.defitem(self) then
    pkg:assert(type(filter)=='string' or not filter, 'wrong filter: %s' % type(filter))
    pkg:assert(self.name, 'not def: %s'%self.name)
	  local d=t.def[self.name]
    pkg:assert(d and is.defroot(d), 'def not found: %s'%self.name)
    return d % (filter or {})
  end end,
  stat = function(self) if is.defitem(self) then
    local filters = self:filters()
    local stat = {}
    for f in iter(filters) do stat[f]=self:count(f) end
    return {
      filters = stat,
      actions = self:actions(),
      total = self:count(),
    }
  end end,
})