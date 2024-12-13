describe("def", function()
  local t, is, def
  setup(function()
    t = require "t"
		is = t.is
    _ = t.storage.mongo ^ t.def
    def = t.def.def
    _ = is
  end)
  it("ok", function()
    assert.is_table(def.__action)
    assert.callable(def.__action.default)
    assert.callable(def.default)

    assert.is_table(getmetatable(def).__action)
    assert.callable(getmetatable(def).__action.default)

    local defs = table.map(def:list())
    assert.is_table(defs)
    assert.is_true(#defs>0)

    local d = def({name='def'})
    assert.equal('def', d.name)

    assert.callable(def.actions)
    assert.values(t.array({'actions', 'default', 'args', 'test', 'list', 'filters', 'collections'}), d:actions())
    assert.values(t.array({'all'}), d:filters())
    assert.values(t.array({}), def({name='collection'}):filters())
    assert.equal(0, t.def.def % {})
  end)
end)