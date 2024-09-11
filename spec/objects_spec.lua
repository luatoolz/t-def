describe("objects", function()
  local t, meta, is, mt, json, td, def, definer, job, auth, remote
  setup(function()
    t = require "t"
    meta = require "meta"
    is = t.is
    mt = meta.mt
    td = require"testdata"

    json = t.format.json

    def = assert(td.def)
    definer = assert(t.definer)

    job = assert(def.job)
    auth = assert(def.auth)
    remote = assert(def.remote)

    _ = is
    _ = json
    _ = auth
  end)
  it("mt", function()
    assert.equal('meta/loader', t.type(td.def))
    assert.equal(definer, meta.module(td.def).handler)
    assert.is_function(mt(remote).ping)
    assert.is_function(remote.ping)
  end)
  it("new", function()
    local i = job({done=true, message='some', created=0})
    assert.same({done=true, message='some', created=0}, i)

    i = job('{"done":false, "message":"another", "created":2}')
    assert.same({done=false, message='another', created=2}, i)

    assert.is_table(mt(i))
  end)
  it("null", function()
    assert.is_table(def.noneexistent)
    assert.equal("y", def.noneexistent('{"x":"y"}').x)
  end)
end)
