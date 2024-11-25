local t=t or require "t"
return setmetatable({
  name='',
}, {
  __computed={
    ok=function(self) return 'ok' end,
  },
  __compute={
    'ok',
  },
})