return setmetatable({
},{
  __action={
    ping=function(self) if self then return 'pong' end end,
  },
})