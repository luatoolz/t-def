describe("objects", function()
  local t, meta, is, mt, array, oid, td, mongo, storage
  setup(function()
    meta = require "meta"
    t = t or require "t"
    is = t.is
    to = t.to
    mt = meta.mt
    array = t.array

    td = require "testdata"
    mongo = (t.storage.mongo ^ t.def) ^ td.def
    oid = mongo.oid
    storage=meta.cache.storage
  end)
  it("mt", function()
    local remote, simple = td.def.remote, td.def.simple
    assert.equal(t.definer, meta.module(t.def).link.handler)

    assert.is_function(mt(remote).ping)
    assert.is_function(remote.ping)
    assert.def(simple)
--    assert.truthy(meta.cache.loaded[simple])
--    assert.factory(simple)
    assert.is_function(mt(simple).__imports._id)

    local item=simple({yes=true})
    assert.is_table(item)
    assert.def(item)
    assert.not_instance(item)
    assert.not_defroot(item)
    assert.defitem(item)

    assert.is_table(item.__imports)
    assert.is_table(item.__required or {})
    assert.is_table(item.__default)
  end)
  it("new", function()
    local o=td.def.job
    assert.is_true(-o)

    assert.is_nil(o())
    assert.is_nil(o(true))
    assert.is_nil(o(false))
    assert.is_nil(o(0))
    assert.is_nil(o(1))
    assert.is_nil(o(2))
    assert.is_nil(o(''))
    assert.is_nil(o(' '))
    assert.is_nil(o('1'))
    assert.is_nil(o('item'))

    assert.def(o({}))

    assert.equal(array(), o({''}))
    assert.equal(array(), o({true}))
    assert.equal(array(), o({false}))
    assert.equal(array(), o({1}))

    local i = o({done=true, message='some', created=0})
    assert.eq({done=true, message='some', created=0}, i)

    i = o('{"done":false, "message":"another", "created":2}')
    assert.equal(i, o{done=false, message='another', created=2})
    assert.equal(o{done=false, message='another', created=2}, i)
    assert.is_table(mt(i))
  end)
  it("noneexistent", function()
    local o = td.def.noneexistent
    local id='66909d26cbade70b6b022b9a'
    assert.is_table(o)
    assert.is_nil(o/'any')
    assert.eq({_id=oid(id)}, o/id)
    assert.eq("y", o('{"x":"y"}').x)
  end)
  it("__add/__sub/__concat/__mod/__unm", function()
    local o = td.def.job

    assert.is_true(-o)
    assert.is_nil(o + nil)
    assert.is_nil(o + true)
    assert.is_nil(o + false)
    assert.is_nil(o + 0)
    assert.is_nil(o + 1)
    assert.is_nil(o + 2)
    assert.is_nil(o + '')
    assert.is_nil(o + ' ')
    assert.is_nil(o + '1')
    assert.is_nil(o + 'item')
    assert.is_nil(o + {''})
    assert.is_nil(o + {true})
    assert.is_nil(o + {false})
    assert.is_nil(o + {1})
    assert.equal(0, o % {})

    assert.is_true(o + {_id='66ef5a258aa5f11c0c094b25', n=1})
    assert.equal(1, to.number(storage[o]))

    assert.equal(1, o % {})
    assert.is_true(o + {_id='66ef5a258aa5f11c0c094b26', n=2, done=true, message='some', created=0})
    assert.equal(2, o % {})
    assert.is_nil(o['66909d26cbade70b6b022b9a'])
    assert.is_true(o + o({_id='66909d26cbade70b6b022b9a', n=3, done=true, message='some', created=0}))
    assert.equal(3, o % {})
    assert.is_true(o + o({_id='66ef5a258aa5f11c0c094b27', n=4}))
    assert.is_true(o + o({_id='66ef5a258aa5f11c0c094b28', n=5}))
    assert.equal(5, o % {})
    assert.equal(o{_id='66909d26cbade70b6b022b9a', n=3, done=true, message='some', created=0}, o['66909d26cbade70b6b022b9a'])
    assert.equal(o{_id='66ef5a258aa5f11c0c094b28', n=5}, o['66ef5a258aa5f11c0c094b28'])

    assert.is_true(o - '66ef5a258aa5f11c0c094b25')
    assert.equal(4, o % {})
    assert.equal('userdata', type((o/{'66909d26cbade70b6b022b9a','66ef5a258aa5f11c0c094b26'})[1]._id))

    assert.equal(2, (o - {'66909d26cbade70b6b022b9a','66ef5a258aa5f11c0c094b26'}).nRemoved)

    assert.equal(2, o % {})
    assert.is_true(o + {_id='66ef5a258aa5f11c0c094b25', n=1})
    assert.equal(3, o % {})
    assert.equal(2, (o - o({{_id='66ef5a258aa5f11c0c094b27', n=4},{_id='66ef5a258aa5f11c0c094b25', n=1}})).nRemoved)
    assert.equal(1, o % {})
    assert.is_true(o - o['66ef5a258aa5f11c0c094b28'])
    assert.equal(0, o % {})
    assert.is_true(o*nil)

    assert.is_true(o + '{"_id":"66ef5a258aa5f11c0c094b25", "n":1}')
    assert.equal(1, o % {})
    assert.is_true(o + o('{"_id":"66ef5a258aa5f11c0c094b26", "n":2}'))
    assert.equal(2, o % {})
    assert.is_true(o*nil)
    assert.equal(0, o % {})
    assert.equal(2, (o + '[{"_id":"66ef5a258aa5f11c0c094b25", "n":1},{"_id":"66ef5a258aa5f11c0c094b26", "n":2}]').nInserted)
    assert.equal(2, o % {})
    assert.equal(2, (o + o('[{"_id":"66ef5a258aa5f11c0c094b27", "n":3},{"_id":"66ef5a258aa5f11c0c094b28", "n":4}]')).nInserted)
    assert.equal(4, o % {})
    assert.is_true(o*nil)

    assert.is_true(o .. '{"_id":"66ef5a258aa5f11c0c094b25", "n":1}')
    assert.equal(1, o % {})
    assert.is_true(o .. o('{"_id":"66ef5a258aa5f11c0c094b26", "n":2}'))
    assert.equal(2, o % {})
    assert.is_true(o*nil)
    assert.equal(0, o % {})
    assert.equal(2, (o .. '[{"_id":"66ef5a258aa5f11c0c094b25", "n":1},{"_id":"66ef5a258aa5f11c0c094b26", "n":2}]').nInserted)
    assert.equal(2, o % {})
    assert.equal(2, (o .. o('[{"_id":"66ef5a258aa5f11c0c094b27", "n":3},{"_id":"66ef5a258aa5f11c0c094b28", "n":4}]')).nInserted)
    assert.equal(4, o % {})

    assert.is_true(o - o('{"_id":"66ef5a258aa5f11c0c094b26", "n":2}')/true)
    assert.is_nil(o['66ef5a258aa5f11c0c094b26'])
    assert.equal(3, o % {})
    assert.is_true(o - o/'66ef5a258aa5f11c0c094b25')
    assert.equal(2, o % {})
    assert.is_true(-o['66ef5a258aa5f11c0c094b28'])
    assert.equal(1, o % {})

    assert.truthy(o['66ef5a258aa5f11c0c094b27'])
    assert.equal('userdata', type(o['66ef5a258aa5f11c0c094b27']._id))

    assert.equal('userdata', type(o({_id='66ef5a258aa5f11c0c094b27', n=3})._id))
    assert.equal(o['66ef5a258aa5f11c0c094b27']._id, o({_id='66ef5a258aa5f11c0c094b27', n=3})._id)
    assert.equal(o['66ef5a258aa5f11c0c094b27'], o({_id='66ef5a258aa5f11c0c094b27', n=3}))

    assert.eq({['$ref']='job',['$id']=oid('66ef5a258aa5f11c0c094b27')}, o['66ef5a258aa5f11c0c094b27'].ref)

    assert.is_true(o*nil)
    assert.equal(0, o % {})
  end)
  it("data", function()
    local o = td.def.data
    assert.equal(0, o % {})
    local item = o({_id='66ef5a258aa5f11c0c094b25', n=1})
    assert.is_true(o + item)
    assert.equal(1, o % {})
    assert.eq(item, o['66ef5a258aa5f11c0c094b25'])
    assert.is_true(to.boolean(item))
    assert.is_true(to.boolean(o['66ef5a258aa5f11c0c094b25']))
    assert.is_true(o*nil)
    assert.equal(0, o % {})
  end)
  it("multi query", function()
    local o = td.def.data
    local sub = table.sub

    assert.is_true(-o)
    assert.equal(0, o % {})

    local x, y =
      o[{query={},as=true,options={limit=1}}],
      o*{query={},as=true,options={limit=1}}
    assert.is_function(x)
    assert.is_function(y)
    assert.is_nil(x())
    assert.is_nil(y())

    local items = o({{_id='66ef5a258aa5f11c0c094b45', n=1},{_id='66ef5a258aa5f11c0c094b46', n=2},{_id='66ef5a258aa5f11c0c094b47', n=3},{_id='66ef5a258aa5f11c0c094b48', n=4}})
    local add = o + items
    assert.equal(4, add.nInserted + add.nUpserted)
    assert.equal(4, o % {})
    assert.is_true(is.array(sub(items,1,1)))

    assert.equal(sub(items,1,1), o[{query={},options={limit=1}}])
    assert.equal(sub(items,1,2), o[{query={},options={limit=2}}])
    assert.equal(sub(items,1,3), o[{query={},options={limit=3}}])
    assert.equal(sub(items,1,4), o[{query={},options={limit=4}}])
    assert.equal(sub(items,1,4), o[{query={},options={limit=5}}])
    assert.equal(items, o[{query={},options={limit=5}}])
    assert.equal(sub(items,1,4), o[{}])
    assert.equal(items, o[{}])

    assert.equal(sub(items,1,1), o*{query={},options={limit=1}})
    assert.equal(sub(items,1,2), o*{query={},options={limit=2}})
    assert.equal(sub(items,1,3), o*{query={},options={limit=3}})
    assert.equal(sub(items,1,4), o*{query={},options={limit=4}})
    assert.equal(sub(items,1,4), o*{query={},options={limit=5}})
    assert.equal(items, o*{query={},options={limit=5}})
    assert.equal(sub(items,1,4), o*{})
    assert.equal(items, o*{})

    assert.equal(sub(items,1,1), array(o[{query={},as=true,options={limit=1}}]))
    assert.equal(sub(items,1,2), array(o[{query={},as=true,options={limit=2}}]))
    assert.equal(sub(items,1,3), array(o[{query={},as=true,options={limit=3}}]))
    assert.equal(sub(items,1,4), array(o[{query={},as=true,options={limit=4}}]))
    assert.equal(sub(items,1,4), array(o[{query={},as=true,options={limit=5}}]))
    assert.equal(items, array(o[{query={},as=true,options={limit=5}}]))

    assert.equal(sub(items,1,1), array(o*{query={},as=true,options={limit=1}}))
    assert.equal(sub(items,1,2), array(o*{query={},as=true,options={limit=2}}))
    assert.equal(sub(items,1,3), array(o*{query={},as=true,options={limit=3}}))
    assert.equal(sub(items,1,4), array(o*{query={},as=true,options={limit=4}}))
    assert.equal(sub(items,1,4), array(o*{query={},as=true,options={limit=5}}))
    assert.equal(items, array(o*{query={},as=true,options={limit=5}}))

    assert.equal(sub(items,2,3), o[{query={},options={skip=1,limit=2}}])
    assert.equal(sub(items,2,4), o[{query={},options={skip=1,limit=3}}])
    assert.equal(sub(items,2,4), o[{query={},options={skip=1,limit=4}}])
    assert.equal(sub(items,2,4), o[{query={},options={skip=1,limit=5}}])

    assert.equal(sub(items,2,2), o*{query={},options={skip=1,limit=1}})
    assert.equal(sub(items,2,3), o*{query={},options={skip=1,limit=2}})
    assert.equal(sub(items,2,4), o*{query={},options={skip=1,limit=3}})
    assert.equal(sub(items,2,4), o*{query={},options={skip=1,limit=4}})
    assert.equal(sub(items,2,4), o*{query={},options={skip=1,limit=5}})

    assert.equal(sub(items,2,2), array(o[{query={},as=true,options={skip=1,limit=1}}]))
    assert.equal(sub(items,2,3), array(o[{query={},as=true,options={skip=1,limit=2}}]))
    assert.equal(sub(items,2,4), array(o[{query={},as=true,options={skip=1,limit=3}}]))
    assert.equal(sub(items,2,4), array(o[{query={},as=true,options={skip=1,limit=4}}]))
    assert.equal(sub(items,2,4), array(o[{query={},as=true,options={skip=1,limit=5}}]))

    assert.equal(sub(items,2,2), array(o*{query={},as=true,options={skip=1,limit=1}}))
    assert.equal(sub(items,2,3), array(o*{query={},as=true,options={skip=1,limit=2}}))
    assert.equal(sub(items,2,4), array(o*{query={},as=true,options={skip=1,limit=3}}))
    assert.equal(sub(items,2,4), array(o*{query={},as=true,options={skip=1,limit=4}}))
    assert.equal(sub(items,2,4), array(o*{query={},as=true,options={skip=1,limit=5}}))

    assert.equal(sub(items,3,3), array(o*{query={},as=true,options={skip=2,limit=1}}))
    assert.equal(sub(items,4,4), array(o*{query={},as=true,options={skip=3,limit=1}}))
    assert.equal(array(), array(o*{query={},as=true,options={skip=4,limit=1}}))

    assert.is_true(o*nil)
    assert.equal(0, o % {})
  end)
  it("__concat", function()
    local o=td.def.job
    assert.is_true(-o)
    assert.is_nil(o .. nil)
    assert.is_nil(o .. true)
    assert.is_nil(o .. false)
    assert.is_nil(o .. 0)
    assert.is_nil(o .. 1)
    assert.is_nil(o .. 2)
    assert.is_nil(o .. '')
    assert.is_nil(o .. ' ')
    assert.is_nil(o .. '1')
    assert.is_nil(o .. 'item')
    assert.is_nil(o .. {''})
    assert.is_nil(o .. {true})
    assert.is_nil(o .. {false})
    assert.is_nil(o .. {1})
    assert.is_nil(o .. {})
    assert.equal(0, o % {})

    assert.equal(1, (o .. {o({done=true, message='some', created=0})}).nInserted)
    assert.equal(1, o % {})

    assert.equal(1, (o .. {{done=true, message='some', created=0}}).nInserted)
    assert.equal(2, o % {})

    local tb = {{_id='66ef5a258aa5f11c0c094b27', n=3},'{"_id":"66ef5a258aa5f11c0c094b26", "n":2}',{_id='66909d26cbade70b6b022b9a', n=4, done=true, message='some', created=0}}
    assert.is_true(is.bulk(tb))
    assert.equal(3, to.number(tb))

    local add = o + tb
    assert.equal(3, add.nInserted)
    assert.equal(3, add.nInserted + add.nUpserted)
    assert.equal(5, to.number(o))
    assert.is_true(o*nil)
    assert.equal(0, o % {})
  end)
  it("__newindex", function()
    local o = td.def.data
    assert.is_true(-o)
    assert.equal(0, o % {})
    local item = o({_id='66ef5a258aa5f11c0c094b25', n=1})
    assert.is_true(o + item)
    assert.equal(1, o % {})
    assert.equal(item, o['66ef5a258aa5f11c0c094b25'])
    assert.is_true(to.boolean(item))
    assert.is_true(to.boolean(o['66ef5a258aa5f11c0c094b25']))
    assert.is_true(o*nil)
    assert.equal(0, o % {})
  end)
  it("__sub", function()
    local o=td.def.job
    assert.is_true(-o)
    assert.is_nil(o - nil)
    assert.is_nil(o - true)
    assert.is_nil(o - false)
    assert.is_nil(o - 0)
    assert.is_nil(o - 1)
    assert.is_nil(o - 2)
    assert.is_nil(o - ' ')
    assert.is_nil(o - '1')
    assert.is_nil(o - 'item')
    assert.is_nil(o - {''})
    assert.is_nil(o - {true})
    assert.is_nil(o - {false})
    assert.is_nil(o - {1})

    assert.is_nil(o - '')
    assert.equal(0, o % {})

    assert.is_true(o + {})
    assert.equal(1, o % {})
    assert.is_true(o + {})
    assert.equal(2, o % {})
    assert.is_true(o - {})
    assert.equal(0, o % {})
  end)
  describe("__div", function()
    describe("auth", function()
      it("defroot", function()
        local auth = td.def.auth
        local id='66909d26cbade70b6b022b9a'
        local token='95687c9a1a88dd2d552438573dd018748dfff0222c76f085515be2dc1db2afa7'

        assert.equal(nil, auth/nil)
        assert.equal(nil, auth/true)
        assert.equal(nil, auth/false)
        assert.equal(nil, auth/0)
        assert.equal(nil, auth/1)
        assert.equal(nil, auth/2)
        assert.equal(nil, auth/' ')
        assert.equal(nil, auth/'1')
        assert.equal(nil, auth/'item')
        assert.equal(nil, auth/{''})
        assert.equal(nil, auth/{true})
        assert.equal(nil, auth/{false})
        assert.equal(nil, auth/{1})
        assert.equal(nil, auth/'')
        assert.same({_id=oid(id)}, auth/id)
        assert.same({token=token}, auth/token)
      end)
      it("defitem", function()
        local auth = td.def.auth
        local id='66909d26cbade70b6b022b9a'
        local token='95687c9a1a88dd2d552438573dd018748dfff0222c76f085515be2dc1db2afa7'
        local item=auth({_id=id, role='root', token=token})

        assert.eq({_id=oid(id)}, item/true)
        assert.equal('_id', item/false)
        assert.equal(nil, item/nil)
        assert.equal(nil, item/0)
        assert.equal(nil, item/1)
        assert.equal(nil, item/2)
        assert.equal(nil, item/' ')
        assert.equal(nil, item/'1')
        assert.equal(nil, item/'item')
        assert.equal(nil, item/{''})
        assert.equal(nil, item/{1})
        assert.equal(nil, item/'')
        assert.equal(nil, item/id)
        assert.equal(nil, item/token)
        assert.same({_id=oid(id)}, item/item)
        assert.same({_id=oid(id)}, auth/item)
      end)
    end)
    it("auth object", function()
      local auth = td.def.auth
      local id='66909d26cbade70b6b022b9a'
      local token='95687c9a1a88dd2d552438573dd018748dfff0222c76f085515be2dc1db2afa7'

      assert.is_table(auth.__id)
      assert.same({_id=oid(id)}, auth/id)
      assert.same({token=token}, auth/token)

--      local o = job({_id=id, done=true, message='some', created=0})
--      assert.equal('_id', o/false)
--      assert.equal('mongo.ObjectID', t.type(o._id))
--      assert.equal('mongo.ObjectID', t.type((o/true)._id))
--      assert.same({_id=oid(id)}, o/true)

--      o=auth({role='root', token=token})
--      assert.eq({role='root', token=token}, o)
--      assert.is_nil(o._id)
--      assert.equal(token, o.token)
--      assert.eq('token', o/false)
--      assert.eq({token=token}, o/true)
    end)
  end)
end)