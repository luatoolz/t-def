local t = require "t"
return setmetatable({
  name='',
  typed_name_computed=t.match.mtname,
  typed_name_computable=t.match.mtname,
}, {
  __computable={
    typed_name_computable=function(self) return '_' .. self.name end,
    untyped_name_computable=function(self) return '_' .. self.name end,
  },
  __computed={
    typed_name_computed=function(self) return '_' .. self.name end,
    untyped_name_computed=function(self) return '_' .. self.name end,
  },
})