local t = t or require "t"
local job=t.def.job

return setmetatable({
  type=t.string,
  id=t.match.md5,
  host=t.string,
  userid=t.number,
  _=[[id]],
  [true]=[[id host]],
}, {
  ping=function(self) return 'pong' end,
  login=function(self, pass) return job({pass=pass}) end,
  __computed={
    session=function(self) end,
    company=function(self) end,
  },
})