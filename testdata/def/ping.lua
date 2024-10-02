return setmetatable({},{
  __action={
    __=function(self) return true end,
    ping=function(self) return true end,
  }
})