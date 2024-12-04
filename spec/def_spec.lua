describe("def", function()
  local t, is, def
  setup(function()
    t = require "t"
		is = t.is
    def = t.def.def
  end)
  it("ok", function()
    assert.is_table(def.__action)
    assert.callable(def.__action.default)
    assert.callable(def.default)

    local defs = table.map(def:list())
    assert.is_table(defs)
    assert.is_true(#defs>0)

		local d = def({name='def'})
		assert.equal('def', d.name)

    assert.callable(def.actions)
		assert.values(t.array({'actions', 'default', 'test', 'list', 'filters'}), d:actions())
		assert.is_true(is.empty(d:filters()))

		assert.values(t.array({'all', 'empty', 'filled'}), def({name='collection'}):filters())
  end)
end)