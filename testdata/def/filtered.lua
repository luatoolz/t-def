return setmetatable({
  stage=1,
},{
  __filter={
    first={stage=1},
    second={stage=2},
  },
})