describe("storage", function()
  local t, meta, job, mcache, td
  setup(function()
    t = require "t"
    meta = require "meta"
    td = require "testdata"
    _ = t.is ^ 'testdata'
    _ = t.storage.mongo ^ td.def
    job = assert(td.def.job)
    mcache = meta.mcache
    storage = t.storage.mongo.cache
  end)
  it("mcache", function()
    assert.is_function(mcache.put.storage)
    assert.equal(t.storage.mongo, storage[td.def])
    assert.equal(t.storage.mongo, storage[td.def])
    assert.truthy(storage[job])
    assert.equal(t.storage.mongo, storage['testdata/def'])
  end)
end)