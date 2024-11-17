return setmetatable({},{
  __filter={
    all={},
    a={a={['$exists']=true}},
    b={a={['$exists']=true}, b={['$exists']=true}},
  },
})