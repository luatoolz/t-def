describe("definer", function()
  local t, is, bson, json, oid, td, array
  setup(function()
    t = require "t"
    is = t.is ^ 'testdata'
    array = t.array
    t.env.MONGO_HOST='127.0.0.1'
    t.env.MONGO_PORT=27015
    td = require "testdata"
    _ = t.storage.mongo ^ td.def
    bson = t.format.bson
    json = t.format.json
    oid = require "t.storage.mongo.oid"
  end)
  describe("definer", function()
    assert.callable(json)
    assert.callable(bson)
    assert.callable(oid)
  end)
  describe("definer", function()
    it("auth", function()
      local o = td.def.auth
      assert.is_true(-o)
      assert.is_callable(getmetatable(o).__imports.role)
      assert.is_callable(getmetatable(o).__imports.token)
      assert.is_table(getmetatable(o).__id)
      assert.is_table(getmetatable(o).__required)

      assert.is_nil(o({role='', token='yy'}))
      assert.is_nil(o({role='root', token='xx'}))
      assert.is_nil(o({role='root'}))
      assert.is_table(o({role='root', token='95687c9a1a88dd2d552438573dd018748dfff0222c76f085515be2dc1db2afa7'}))

      assert.is_table(array({{role='root', token='95687c9a1a88dd2d552438573dd018748dfff0222c76f085515be2dc1db2afa7'},
                        {role='traffer', token='46db395df332f18b437d572837d314e421804aaed0f229872ce7d8825d11ff9a'}}) * o)

      assert.is_table(o .. o({{role='root', token='95687c9a1a88dd2d552438573dd018748dfff0222c76f085515be2dc1db2afa7'},
                        {role='traffer', token='46db395df332f18b437d572837d314e421804aaed0f229872ce7d8825d11ff9a'}}))

      local jj = '[{"token":"95687c9a1a88dd2d552438573dd018748dfff0222c76f085515be2dc1db2afa7","role":"root"},' ..
                 '{"token":"46db395df332f18b437d572837d314e421804aaed0f229872ce7d8825d11ff9a","role":"traffer"},' ..
                 '{"token":"60879afb54028243bb82726a5485819a8bbcacd1df738439bfdf06bc3ea628d0","role":"panel"}]'

      assert.is_true(-o)
      assert.is_table(o + jj)
    end)
    it("remote", function()
      local o = td.def.remote
      assert.is_callable(getmetatable(o).__imports.type)
      assert.is_callable(getmetatable(o).__imports.id)
      assert.is_table(getmetatable(o).__id)
      assert.is_table(getmetatable(o).__required)
      assert.is_callable(getmetatable(o).ping)
      assert.is_callable(getmetatable(o).login)

      assert.is_nil(o({id='', host='xx'}))
      assert.is_table(o({id='ba1f2511fc30423bdbb183fe33f3dd0f', host='xx'}))
    end)
    it("simple", function()
      local o = td.def.simple
      assert.is_table(o)
      assert.is_callable(o)

      assert.eq({}, o{})
      assert.eq({yes=false,no=true,one=3,pi=1}, o({yes=false,no=true,one=2.64,pi=1}))
      assert.eq({chars='qwe',digits='123'}, o({chars='123qwe456',digits='qwe123ert'}))
      assert.eq({zero=77,empty='some'}, o({zero=77,empty='some'}))
      assert.eq({zero=77,empty='77'}, o({zero='77',empty=77}))
    end)
    it("simpledef", function()
      local o = td.def.simpledef
      assert.is_table(o)
      assert.is_callable(o)

      assert.eq({yes=true,no=false,one=1,pi=3.14}, o({}))
      assert.eq({yes=false,no=true,one=3,pi=1}, o({yes=false,no=true,one=2.64,pi=1}))
      assert.eq({yes=true,no=false,one=1,pi=3.14,chars='qwe',digits='123'}, o({chars='123qwe456',digits='qwe123ert'}))
      assert.eq({yes=true,no=false,one=1,pi=3.14,zero=77,empty='some'}, o({zero=77,empty='some'}))
      assert.eq({yes=true,no=false,one=1,pi=3.14,zero=77,empty='77'}, o({zero='77',empty=77}))
    end)
    it("simdate", function()
      local date = t.date
      local o = td.def.simdate
      assert.is_table(o)
      assert.is_callable(o)

      local x=o({no=false})
      x.ts=date()
      assert.eq({yes=true,no=false,one=1,pi=3.14,ts=date()}, x)
      local __export = (getmetatable(x.ts) or {}).__export
      assert.is_function(__export)

      assert.equal(o(x), x)
      assert.equal(x, o(bson(x)))
      assert.equal(x, o(bson(x):value()))
      assert.equal(x, o(json(x)))

      assert.keys({'yes', 'no', 'one', 'pi'}, o({yes=false}))
      assert.eq({yes=false,no=true,one=3,pi=1}, o({yes=false,no=true,one=2.64,pi=1}))
      assert.eq({yes=true,no=false,one=1,pi=3.14,chars='qwe',digits='123'}, o({chars='123qwe456',digits='qwe123ert'}))
      assert.eq({yes=true,no=false,one=1,pi=3.14,zero=77,empty='some'}, o({zero=77,empty='some'}))
      assert.eq({yes=true,no=false,one=1,pi=3.14,zero=77,empty='77'}, o({zero='77',empty=77}))
    end)
    it("x", function()
      local o = td.def.x
      assert.is_nil(o())
      assert.is_nil(o(''))
      assert.equal(o({}),o({}))
      assert.equal(o({}),o('{}'))
      assert.equal(o(t.array()),o('[]'))

      assert.equal(o({{}}),o('[{}]'))

      assert.equal(o({{},{}}),o('[{},{}]'))
      assert.equal(o({{},{},{}}),o('[{},{},{}]'))
      assert.equal(o({{},{},{},{}}),o('[{},{},{},{}]'))
      assert.equal(o({n=1}),o({n=1}))
      assert.equal(o({n=0}),o({n=0}))
      assert.equal(o({n=0,x=''}),o({n=0,x=''}))
      assert.equal(o({x='yes',n=7}),o({n=7,x='yes'}))
      assert.equal(o({x='yes',n=7}),o('{"n":7,"x":"yes"}'))
      assert.equal(o({x='yes',n=7}),o(bson('{"n":7,"x":"yes"}')))
      assert.equal(o({{n=0,x=''},{n=1,x='1'},{n=3,x='q'},{n=-11,x='qwe'}}),o({{n=0,x=''},{n=1,x='1'},{n=3,x='q'},{n=-11,x='qwe'}}))
      assert.equal(o({{n=0,x=''},{n=1,x='1'},{n=3,x='q'},{n=-11,x='qwe'}}),o('[{"n":0,"x":""},{"n":1,"x":"1"},{"n":3,"x":"q"},{"n":-11,"x":"qwe"}]'))

      local items={o({[true]=7,yes='da'}),o(),o({}),o({{}}),o({{},{}}),o({{},{},{}}),o({{},{},{},{}}),o({n=1}),o({n=1}),o({n=0}),o({n=0}),o({n=0,x=''}),o({x='yes',n=7}),o({x='yes',n=7}),
        o({x='yes',n=7}),o({{n=0,x=''},{n=1,x='1'},{n=3,x='q'},{n=-11,x='qwe'}}),o({{n=0,x=''},{n=1,x='1'},{n=3,x='q'},{n=-11,x='qwe'}})}

      for i,v in ipairs(items) do
        assert.equal(v, o(v))
        assert.equal(v, o(json(v)))
        assert.equal(v, o(bson(v)))
      end
      for i,v in ipairs(items) do
        if not is.bulk(v) then v._id=oid() end
        assert.equal(v, o(v))
        assert.equal(v, o(json(v)))
        assert.equal(v, o(bson(v)))
      end
    end)
    it("filtered", function()
      local o = td.def.filtered

      assert.is_table(o)
      assert.is_callable(o)
--      assert.is_callable(getmetatable(o).__imports.stage)
      assert.is_table(getmetatable(o).__filter)
      assert.is_table(getmetatable(o).__filter.first)
      assert.is_table(getmetatable(o).__filter.second)

      assert.is_nil(o/'noneexistent')
      assert.is_table(o/'first')
      assert.is_table(o/'second')
      assert.equal(1, (o/'first' or {}).stage)
      assert.equal(2, (o/'second' or {}).stage)

      assert.is_true(o-{})
      assert.equal(0, o % {})
      assert.equal(0, o % 'first')
      assert.equal(0, o % 'second')

      assert.is_true(o + {stage=1})
      assert.equal(1, o % {})
      assert.equal(1, o % 'first')
      assert.equal(0, o % 'second')

      local first = o.first
      assert.ofarray(first)
      assert.equal(1, #first)
      assert.equal('testdata/def filtered', t.type(first[1]))
      assert.equal(1, (first[1] or {}).stage)

      assert.is_true(o + {stage=2})
      assert.equal(2, o % {})
      assert.equal(1, o % 'first')
      assert.equal(1, o % 'second')

      local second = o.second
      assert.ofarray(second)
      assert.equal(1, #second)
      assert.equal(2, (second[1] or {}).stage)

      assert.ok(o*nil)
      assert.equal(0, o % {})
      assert.equal(0, o % 'first')
      assert.equal(0, o % 'second')
    end)
    it("filteredfields", function()
      local o = td.def.filteredfields

      assert.ok(o*nil)
      assert.is_table(o)
      assert.is_callable(o)
      assert.is_table(getmetatable(o).__filter)
      assert.is_table(getmetatable(o).__filter.a)
      assert.is_table(getmetatable(o).__filter.b)
      assert.is_table(getmetatable(o).__filter.all)

      local x, a, b, c = o({_id='67001df7d64d4d4c2a08fa9b',x=1}),
                         o({_id='67001df7d64d4d4c2a08fa9c',x=2,a=2}),
                         o({_id='67001df7d64d4d4c2a08fa9d',x=3,a=3,b=3}),
                         o({_id='67001df7d64d4d4c2a08fa9e',x=4,a=4,b=4,c=4})

      assert.equal(4, (o .. {x, a, b, c}).nInserted)
      assert.equal(t.array{a,b,c}, o.a)
      assert.equal(t.array{b,c},   o.b)
      assert.equal(t.array{x,a,b,c}, o.all)
      _ = -o
    end)
    it("exec", function()
      local o = td.def.exec
      assert.is_table(o)
      assert.is_callable(o)
      assert.is_callable(getmetatable(o).ping)
      assert.equal('pong', o({}):ping())
    end)
    it("actiondefault", function()
      local o = td.def.actiondefault
      assert.is_table(o)
      assert.is_callable(o)
      assert.is_table(o.__action)
      assert.is_callable(o.__action.__)
      assert.is_callable(o.__)
      assert.is_callable(o[''])
      assert.is_nil(o['']())
      assert.is_nil(o['__']())
      assert.equal('pong', o[''](o))
      assert.equal('pong', o['__'](o))
    end)
    it("action", function()
      local o = td.def.action
      assert.is_table(o)
      assert.is_callable(o)
      assert.is_table(o.__action)
      assert.is_callable(o.__action.ping)
      assert.equal('pong', o:ping())
      assert.equal('pong', o['ping'](o))
    end)
    it("ping", function()
      local o = td.def.ping
      assert.is_table(o)
      assert.is_callable(o)
      assert.is_table(o.__action)
      assert.is_callable(o.__action.ping)
      assert.is_callable(o.__action.__)
      assert.equal(true, o:ping())
      assert.equal(true, o['ping'](o))
      assert.equal(true, o['__'](o))
      assert.equal(true, o[''](o))

      assert.is_nil(o/'ping')
    end)
  end)
end)