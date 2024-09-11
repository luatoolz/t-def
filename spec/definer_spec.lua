local getmetatable=debug and debug.getmetatable or getmetatable
describe("definer", function()
  local t, td, bson, json
  setup(function()
    t = require "t"
    td = require "testdata"
    bson = t.format.bson
    json = t.format.json
  end)
  describe("definer", function()
    it("auth", function()
      local o = td.def.auth
      assert.is_callable(getmetatable(o).__imports.role)
      assert.is_callable(getmetatable(o).__imports.token)
      assert.is_table(getmetatable(o).__id)
      assert.is_table(getmetatable(o).__required)

      o = o({role='root', token='xx'})
      assert.is_table(o)
    end)
    it("remote", function()
      local o = td.def.remote
      assert.is_callable(getmetatable(o).__imports.type)
      assert.is_callable(getmetatable(o).__imports.id)
      assert.is_table(getmetatable(o).__id)
      assert.is_table(getmetatable(o).__required)
      assert.is_callable(getmetatable(o).ping)
      assert.is_callable(getmetatable(o).login)

      o = o({id='q', host='xx'})
      assert.is_table(o)
    end)
    it("simple", function()
      local o = td.def.simple
      assert.is_table(o)
      assert.is_callable(o)

      assert.same({}, o({}))
      assert.same({yes=false,no=true,one=3,pi=1}, o({yes=false,no=true,one=2.64,pi=1}))
      assert.same({chars='qwe',digits='123'}, o({chars='123qwe456',digits='qwe123ert'}))
      assert.same({zero=77,empty='some'}, o({zero=77,empty='some'}))
      assert.same({zero=77,empty='77'}, o({zero='77',empty=77}))
    end)
    it("simpledef", function()
      local o = td.def.simpledef
      assert.is_table(o)
      assert.is_callable(o)

      assert.same({yes=true,no=false,one=1,pi=3.14}, o())
      assert.same({yes=true,no=false,one=1,pi=3.14}, o({}))
      assert.same({yes=false,no=true,one=3,pi=1}, o({yes=false,no=true,one=2.64,pi=1}))
      assert.same({yes=true,no=false,one=1,pi=3.14,chars='qwe',digits='123'}, o({chars='123qwe456',digits='qwe123ert'}))
      assert.same({yes=true,no=false,one=1,pi=3.14,zero=77,empty='some'}, o({zero=77,empty='some'}))
      assert.same({yes=true,no=false,one=1,pi=3.14,zero=77,empty='77'}, o({zero='77',empty=77}))
    end)
    it("simdate", function()
      local date = t.date
      local o = td.def.simdate
      assert.is_table(o)
      assert.is_callable(o)

      local x=o()
      x.ts=date()
      assert.same({yes=true,no=false,one=1,pi=3.14,ts=date()}, x)
      local __export = (getmetatable(x.ts) or {}).__export
      assert.is_function(__export)

      local bs = bson(x)
      assert.same(x, o(bs:value()))
      assert.same(x, o(json(x)))

      assert.keys({'yes', 'no', 'one', 'pi'}, o({}))
      assert.same({yes=false,no=true,one=3,pi=1}, o({yes=false,no=true,one=2.64,pi=1}))
      assert.same({yes=true,no=false,one=1,pi=3.14,chars='qwe',digits='123'}, o({chars='123qwe456',digits='qwe123ert'}))
      assert.same({yes=true,no=false,one=1,pi=3.14,zero=77,empty='some'}, o({zero=77,empty='some'}))
      assert.same({yes=true,no=false,one=1,pi=3.14,zero=77,empty='77'}, o({zero='77',empty=77}))
    end)
  end)
end)
