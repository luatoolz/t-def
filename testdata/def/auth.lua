local t=t or require "t"
return setmetatable({
  token=t.match.x64,
  role='',
  _='token',
  [true]='token role',
},{
  __filter={
    root={role='root'},
    traffer={role='traffer'},
    panel={role='panel'},
  },
})