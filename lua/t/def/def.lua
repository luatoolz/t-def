local t=t or require "t"
local pkg=...
local is=t.is
local iter=table.iter
return setmetatable({
  name='[A-Za-z%d%/%._-]+$',
}, {
  __id={'name'},
  __required={'name'},
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
        rv[name]=self({name=name}):stat()
      end
      return rv
    end,
  },
	test=function(self) return 'method' end,
	actions=function(self) if is.defitem(self) then
	    local d=t.def[self.name]
	    if not d then return pkg:error('def not found', self.name) end
      return t.array(table.keys(d.__action))
  end end,
  filters=function(self) if is.defitem(self) then
    local d=t.def[self.name]
    if not d then return pkg:error('def not found', self.name) end
    return t.array(table.keys(d.__filter))
  end end,
	count=function(self, filter) if is.defitem(self) then
	    local d=t.def[self.name]
	    if not d then return pkg:error('def not found', self.name) end
      return d % (filter or {})
  end end,
  stat = function(self) if is.defitem(self) then
    local filters = self:filters()
    local stat = {}
    for _,f in ipairs(filters) do stat[f]=self:count(f) end
    return {
      filters = stat,
      actions = self:actions(),
      total = self:count(),
    }
  end end,
})