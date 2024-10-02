return setmetatable({
},{
  ping=function(self) return 'pong' end,
})