local t=t or require "t"
local meta = require "meta"
local mt = meta.mt
local object = t.object
local pkg = t.pkg(...)

local field_type = pkg.field_type
local uniq_split = pkg.uniq_split
local tables = pkg.tables
local defroot = pkg.defroot

local off = {
  _=true,
  [true]=true,
}

-- object definition, name (id), path
-- self could nil
return function(imports, name, path)
  imports=imports or {}
  local self = setmetatable({},getmetatable(imports) or {})

  if name and path and #path>#name then
    mt(self).__name='%s %s'%{path:sub(1,#path-#name-1),name}
  else
    if path then mt(self).__name=path else mt(self).__name='unknown' end
  end
  if name then mt(self).__def=name else mt(self).__def='unknown' end

  if type(mt(self).__action)=='function' then
    local __action={default=mt(self).__action}
    mt(self).__action=__action
  end

  for k,_ in pairs(tables) do
    mt(self)[k]=mt(self)[k] or mt(object)[k] or {}
  end

  mt(self).__imports = mt(self).__imports or {}
  for k,v in pairs(imports) do
    if not off[k] then
      local a,b = field_type(v)
      mt(self).__imports[k] = a
      mt(self).__default[k] = b
    end
  end
  for k,v in pairs(mt(object).__imports or {}) do
    mt(self).__imports[k]=mt(self).__imports[k] or v
  end

  if imports._ then
    mt(self).__id = uniq_split(imports._) or mt(self).__id or {}
    imports._=nil
  end
  if imports[true] then
    mt(self).__required = uniq_split(imports[true]) or mt(self).__required or {}
    imports[true]=nil
  end

  defroot[self]=mt(self).__name

  for k,_ in pairs(tables) do
    if type(mt(self)[k])=='table' and type(next(mt(self)[k]))=='nil' then
      mt(self)[k]=nil
    end
  end
  return mt(self,getmetatable(object),false)
end