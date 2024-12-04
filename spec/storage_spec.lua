describe("storage", function()
  local t, meta, job, cache, td
  setup(function()
    t = require "t"
    meta = require "meta"
    td = require "testdata"
    _ = t.is ^ 'testdata'
    _ = t.storage.mongo ^ td.def
    job = assert(td.def.job)
    cache = meta.cache
    storage = t.storage.mongo.cache
  end)
  it("cache", function()
    assert.is_function(cache.put.storage)
    assert.equal(t.storage.mongo, storage[td.def])
    assert.equal(t.storage.mongo, storage[td.def])
    assert.truthy(storage[job])
    assert.equal(t.storage.mongo, storage['testdata/def'])
  end)
end)