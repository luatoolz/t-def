local t = t or require "t"
local td = require"testdata"

return setmetatable({
  type=t.string,
  id=t.string,
  host=t.string,
  userid=t.number,
  [true]={
    id=[[id]],
    required=[[id host]],
  }
}, {
  ping=function(self) (ngx and ngx.say or print)('pong') end,
  login=function(self, pass) return td.def.job() end,
  __computed={
    session=function(self) end,
    company=function(self) end,
  },
})