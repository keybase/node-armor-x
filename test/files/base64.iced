{prng} = require 'crypto'

basex = require '../..'
b64enc = basex.encoding.b64.encoding

b64stripped =
  encode : (x) ->
    r = new RegExp('=', 'g')
    x.toString('base64').replace(r, '')
  decode : (x) ->
    until (x.length % 4) is 0
      x += "="
    return new Buffer x, 'base64'

exports.test_b64_compat = (T,cb) ->
  x = new Buffer "Hello world! It is I, Bubba Karp.", 'utf8'
  pad = new Buffer (0 for i in [0...16])
  for i in [0..x.length]
    for padlen in [0...pad.length]
      buf = Buffer.concat [ pad[0...padlen], x[0...i] ]
      e1 = b64stripped.encode buf
      e2 = b64enc.encode buf, true
      T.equal e1, e2, "got same encryption buf=#{buf}"
  cb()
