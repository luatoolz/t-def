local t=t or require "t"
local pkg = t.pkg(...)
local call, computable, tables, save, sub =
  pkg.call,
  pkg.computable,
  pkg.tables,
  table.save,
  '_'

return function(self, key)
  if type(self)=='table' then
    local mt=getmetatable(self)
  if mt then
  return mt[key]
    or (tables[key] and {})
    or call(mt.__preindex, self, key)
    or computable(self, mt.__computable, key)
    or save(rawget(self, sub), key, computable(self, mt.__computed, key))
    or call(mt.__postindex, self, key)
  end end end