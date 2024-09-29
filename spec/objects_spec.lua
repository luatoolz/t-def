describe("objects", function()
  local t, meta, is, mt, json, oid, ii, def, definer, job, auth, remote, simple, storage, cache, __storage
  setup(function()
    t = t or require "t"
    t.env.MONGO_HOST='127.0.0.1'
    meta = require "meta"
    is = t.is
    mt = meta.mt
    meta.no.errors(true)
    _ = t.storage.mongo ^ t.def
    ii = t.storage.mongo.ii

    json = t.format.json
    oid = t.storage.mongo.oid

    def = assert(t.def)
    definer = assert(t.definer)

    job = assert(def.job)
    auth = assert(def.auth)
    remote = assert(def.remote)
    simple = assert(def.simple)

    _ = is
    _ = json
    _ = auth
    _ = ii

    cache=meta.cache
    __storage = cache.storage
    storage=setmetatable({},{__index=function(_, self) return __storage[self][tostring(self)] end })
    assert.is_true(-job)
    meta.log.report=false
  end)
  it("mt", function()
    assert.equal(definer, meta.module(t.def).link.handler)
    assert.is_function(mt(remote).ping)
    assert.is_function(remote.ping)
    assert.def(simple)
    assert.truthy(meta.cache.loaded[simple])
    assert.factory(simple)
    assert.is_function(mt(simple).__imports._id)

    local item=simple({yes=true})
    assert.is_table(item)
    assert.def(item)
    assert.not_factory(item)
    assert.not_defroot(item)
    assert.defitem(item)

    assert.is_table(item.__imports)
    assert.is_table(item.__required or {})
    assert.is_table(item.__default)
  end)
  it("new", function()
    assert.is_nil(job())
    assert.is_nil(job(true))
    assert.is_nil(job(false))
    assert.is_nil(job(0))
    assert.is_nil(job(1))
    assert.is_nil(job(2))
    assert.is_nil(job(''))
    assert.is_nil(job(' '))
    assert.is_nil(job('1'))
    assert.is_nil(job('item'))

    assert.equal(t.array(), job({''}))
    assert.equal(t.array(), job({true}))
    assert.equal(t.array(), job({false}))
    assert.equal(t.array(), job({1}))

    local i = job({done=true, message='some', created=0})
    assert.eq({done=true, message='some', created=0}, i)

    i = job('{"done":false, "message":"another", "created":2}')
    assert.eq(i, {done=false, message='another', created=2})
    assert.eq({done=false, message='another', created=2}, i)
    assert.is_table(mt(i))
  end)
  it("noneexistent", function()
    local id='66909d26cbade70b6b022b9a'
    assert.is_table(def.noneexistent)
    assert.is_nil(def.noneexistent/'any')
    assert.eq({_id=oid(id)}, def.noneexistent/id)
    assert.equal("y", def.noneexistent('{"x":"y"}').x)
  end)
  it("__add/__sub/__concat/__mod/__unm", function()
    assert.is_true(job*nil)
    assert.is_nil(job + nil)
    assert.is_nil(job + true)
    assert.is_nil(job + false)
    assert.is_nil(job + 0)
    assert.is_nil(job + 1)
    assert.is_nil(job + 2)
    assert.is_nil(job + '')
    assert.is_nil(job + ' ')
    assert.is_nil(job + '1')
    assert.is_nil(job + 'item')
    assert.is_nil(job + {''})
    assert.is_nil(job + {true})
    assert.is_nil(job + {false})
    assert.is_nil(job + {1})
    assert.equal(0, job % {})

    assert.is_true(job + {_id='66ef5a258aa5f11c0c094b25', n=1})
    assert.equal(1, tonumber(storage[job]))

    assert.equal(1, job % {})
    assert.is_true(job + {_id='66ef5a258aa5f11c0c094b26', n=2, done=true, message='some', created=0})
    assert.equal(2, job % {})
    assert.is_nil(job['66909d26cbade70b6b022b9a'])
    assert.is_true(job + job({_id='66909d26cbade70b6b022b9a', n=3, done=true, message='some', created=0}))
    assert.equal(3, job % {})
    assert.is_true(job + job({_id='66ef5a258aa5f11c0c094b27', n=4}))
    assert.is_true(job + job({_id='66ef5a258aa5f11c0c094b28', n=5}))
    assert.equal(5, job % {})
    assert.eq({_id='66909d26cbade70b6b022b9a', n=3, done=true, message='some', created=0}, job['66909d26cbade70b6b022b9a'])
    assert.eq({_id='66ef5a258aa5f11c0c094b28', n=5}, job['66ef5a258aa5f11c0c094b28'])

    assert.is_true(job - '66ef5a258aa5f11c0c094b25')
    assert.equal(4, job % {})
    assert.equal('userdata', type((job/{'66909d26cbade70b6b022b9a','66ef5a258aa5f11c0c094b26'})[1]._id))
    assert.equal(2, (job - {'66909d26cbade70b6b022b9a','66ef5a258aa5f11c0c094b26'}).nRemoved)

    assert.equal(2, job % {})
    assert.is_true(job + {_id='66ef5a258aa5f11c0c094b25', n=1})
    assert.equal(3, job % {})
    assert.equal(2, (job - job({{_id='66ef5a258aa5f11c0c094b27', n=4},{_id='66ef5a258aa5f11c0c094b25', n=1}})).nRemoved)
    assert.equal(1, job % {})
    assert.is_true(job - job['66ef5a258aa5f11c0c094b28'])
    assert.equal(0, job % {})
    assert.is_true(job*nil)

    assert.is_true(job + '{"_id":"66ef5a258aa5f11c0c094b25", "n":1}')
    assert.equal(1, job % {})
    assert.is_true(job + job('{"_id":"66ef5a258aa5f11c0c094b26", "n":2}'))
    assert.equal(2, job % {})
    assert.is_true(job*nil)
    assert.equal(0, job % {})
    assert.equal(2, (job + '[{"_id":"66ef5a258aa5f11c0c094b25", "n":1},{"_id":"66ef5a258aa5f11c0c094b26", "n":2}]').nInserted)
    assert.equal(2, job % {})
    assert.equal(2, (job + job('[{"_id":"66ef5a258aa5f11c0c094b27", "n":3},{"_id":"66ef5a258aa5f11c0c094b28", "n":4}]')).nInserted)
    assert.equal(4, job % {})
    assert.is_true(job*nil)

    assert.is_true(job .. '{"_id":"66ef5a258aa5f11c0c094b25", "n":1}')
    assert.equal(1, job % {})
    assert.is_true(job .. job('{"_id":"66ef5a258aa5f11c0c094b26", "n":2}'))
    assert.equal(2, job % {})
    assert.is_true(job*nil)
    assert.equal(0, job % {})
    assert.equal(2, (job .. '[{"_id":"66ef5a258aa5f11c0c094b25", "n":1},{"_id":"66ef5a258aa5f11c0c094b26", "n":2}]').nInserted)
    assert.equal(2, job % {})
    assert.equal(2, (job .. job('[{"_id":"66ef5a258aa5f11c0c094b27", "n":3},{"_id":"66ef5a258aa5f11c0c094b28", "n":4}]')).nInserted)
    assert.equal(4, job % {})

    assert.is_true(job - job('{"_id":"66ef5a258aa5f11c0c094b26", "n":2}')/true)
    assert.is_nil(job['66ef5a258aa5f11c0c094b26'])
    assert.equal(3, job % {})
    assert.is_true(job - job/'66ef5a258aa5f11c0c094b25')
    assert.equal(2, job % {})
    assert.is_true(-job['66ef5a258aa5f11c0c094b28'])
    assert.equal(1, job % {})

    assert.truthy(job['66ef5a258aa5f11c0c094b27'])
    assert.equal('userdata', type(job['66ef5a258aa5f11c0c094b27']._id))

    assert.equal('userdata', type(job({_id='66ef5a258aa5f11c0c094b27', n=3})._id))
    assert.equal(job['66ef5a258aa5f11c0c094b27']._id, job({_id='66ef5a258aa5f11c0c094b27', n=3})._id)
    assert.equal(job['66ef5a258aa5f11c0c094b27'], job({_id='66ef5a258aa5f11c0c094b27', n=3}))

    assert.eq({['$ref']='job',['$id']={_id=oid('66ef5a258aa5f11c0c094b27')}}, job['66ef5a258aa5f11c0c094b27'].ref)

    assert.is_true(job*nil)
    assert.equal(0, job % {})
  end)
  it("__concat", function()
    assert.is_true(job*nil)
--    assert.is_nil(job .. nil)
    assert.is_nil(job .. true)
    assert.is_nil(job .. false)
    assert.is_nil(job .. 0)
    assert.is_nil(job .. 1)
    assert.is_nil(job .. 2)
    assert.is_nil(job .. '')
    assert.is_nil(job .. ' ')
    assert.is_nil(job .. '1')
    assert.is_nil(job .. 'item')

--    assert.equal('', is.empty(job({''})))

    assert.is_nil(job .. {''})
    assert.is_nil(job .. {true})
    assert.is_nil(job .. {false})
    assert.is_nil(job .. {1})
    assert.is_nil(job .. {})
    assert.equal(0, job % {})

    assert.equal(1, (job .. {{done=true, message='some', created=0}}).nInserted)
    assert.equal(1, job % {})

    assert.equal(1, (job .. {job({done=true, message='some', created=0})}).nInserted)
    assert.equal(2, job % {})

    local tb = {{_id='66ef5a258aa5f11c0c094b27', n=3},'{"_id":"66ef5a258aa5f11c0c094b26", "n":2}',{_id='66909d26cbade70b6b022b9a', n=4, done=true, message='some', created=0}}
--    assert.equal('', tb)
    assert.is_true(is.bulk(tb))
--    assert.equal('t/array', t.type(tb))
--    assert.equal('userdata', type(tb[1]._id))
    assert.equal(3, tonumber(tb))
    assert.equal(3, (job + tb).nInserted)
--    assert.is_true(toboolean(job .. tb))
--    assert.is_true(job .. {{_id='66ef5a258aa5f11c0c094b27', n=3},'{"_id":"66ef5a258aa5f11c0c094b26", "n":2}',{_id='66909d26cbade70b6b022b9a', n=4, done=true, message='some', created=0}})

    assert.equal(5, tonumber(job))
    assert.is_true(job*nil)
    assert.equal(0, job % {})
  end)
  it("__sub", function()
    assert.ok(job*nil)
    assert.is_nil(job - nil)
    assert.is_nil(job - true)
    assert.is_nil(job - false)
    assert.is_nil(job - 0)
    assert.is_nil(job - 1)
    assert.is_nil(job - 2)
    assert.is_nil(job - ' ')
    assert.is_nil(job - '1')
    assert.is_nil(job - 'item')
    assert.is_nil(job - {''})
    assert.is_nil(job - {true})
    assert.is_nil(job - {false})
    assert.is_nil(job - {1})

    assert.is_nil(job - '')
    assert.equal(0, job % {})

    assert.is_true(job + {})
    assert.equal(1, job % {})
    assert.is_true(job + {})
    assert.equal(2, job % {})
    assert.is_true(job - {})
    assert.equal(0, job % {})
  end)
  it("__div", function()
    local id='66909d26cbade70b6b022b9a'
    local token='95687c9a1a88dd2d552438573dd018748dfff0222c76f085515be2dc1db2afa7'

    assert.is_table(t.def.auth.__id)
    assert.eq({_id=oid(id)}, t.def.auth/id)
    assert.eq({token=token}, t.def.auth/token)

    local o=job({_id=id, done=true, message='some', created=0})
    assert.equal('_id', o/false)
    assert.equal('mongo.ObjectID', t.type(o._id))
    assert.equal('mongo.ObjectID', t.type((o/true)._id))
    assert.same({_id=oid(id)}, o/true)

    o=t.def.auth({role='root', token=token})
    assert.eq({role='root', token=token}, o)
    assert.is_nil(o._id)
    assert.equal(token, o.token)
    assert.eq('token', o/false)
    assert.eq({token=token}, o/true)
  end)
end)
