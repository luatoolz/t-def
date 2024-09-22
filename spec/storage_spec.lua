describe("storage", function()
  local t, meta, is, td, job, cache
  setup(function()
    t = t or require "t"
    t.env.MONGO_HOST='127.0.0.1'
    meta = require "meta"
    is = t.is ^ 'testdata'
    td = require "testdata"
    job = assert(td.def.job)
    cache = meta.cache
    storage = cache.storage
    local _ = is
  end)
  it("cache", function()
    assert.is_function(cache.objnormalize.storage)
    assert.equal(t.storage.mongo, storage[td.def])
    local f = cache.objnormalize.storage
    assert.equal('testdata/def', f(td.def))
    assert.equal('testdata/def', f(job))
    assert.equal(t.storage.mongo, storage[job])
    assert.equal(t.storage.mongo, storage[job({no=false})])
  end)
end)
