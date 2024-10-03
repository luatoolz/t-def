describe("storage", function()
  local t, meta, job, cache
  setup(function()
    t = require "t"
    t.env.MONGO_HOST='127.0.0.1'
    t.env.MONGO_PORT=27015
    meta = require "meta"
    _ = t.storage.mongo ^ t.def
    job = assert(t.def.job)
    cache = meta.cache
    storage = cache.storage
  end)
  it("cache", function()
    assert.is_function(cache.objnormalize.storage)
    assert.equal(t.storage.mongo, storage[t.def])
    local f = cache.objnormalize.storage
    assert.equal('t/def', f(t.def))
    assert.equal('t/def', f(job))
    assert.equal(t.storage.mongo, storage[job])
    assert.equal(t.storage.mongo, storage[job({no=false})])
  end)
end)
