return setmetatable({
},{
  __action=function(self) if self then return 'pong' end end,
})