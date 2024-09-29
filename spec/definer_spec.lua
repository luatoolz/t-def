local getmetatable=debug and debug.getmetatable or getmetatable
describe("definer", function()
  local t, is, bson, json, oid, td
  setup(function()
    t = t or require "t"
    is = t.is ^ 'testdata'
    t.env.MONGO_HOST='127.0.0.1'
    td = require "testdata"
    _ = t.storage.mongo ^ td.def
    bson = t.format.bson
    json = t.format.json
    oid = require "t.storage.mongo.oid"
  end)
  describe("definer", function()
    it("auth", function()
      local o = td.def.auth
      assert.is_callable(getmetatable(o).__imports.role)
      assert.is_callable(getmetatable(o).__imports.token)
      assert.is_table(getmetatable(o).__id)
      assert.is_table(getmetatable(o).__required)

      assert.is_nil(o({role='', token='yy'}))
      assert.is_nil(o({role='root', token='xx'}))
      assert.is_nil(o({role='root'}))
      assert.is_table(o({role='root', token='e7df7cd2ca07f4f1ab415d457a6e1c13'}))

      local jj = '[{"token":"95687c9a1a88dd2d552438573dd018748dfff0222c76f085515be2dc1db2afa7","role":"root"},' ..
        '{"token":"46db395df332f18b437d572837d314e421804aaed0f229872ce7d8825d11ff9a","role":"traffer"},' ..
        '{"token":"60879afb54028243bb82726a5485819a8bbcacd1df738439bfdf06bc3ea628d0","role":"panel"}]'
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

--      assert.eq({yes=true,no=false,one=1,pi=3.14}, o())
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
      assert.equal(o({}),o('[]'))

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
  end)
end)
