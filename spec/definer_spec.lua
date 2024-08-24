describe("definer", function()
  local td
  setup(function()
    require "t"
    td = require "testdata"
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
  end)
end)
