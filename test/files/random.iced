{prng} = require 'crypto'

armorx = require '../..'

test = (T,nm,raw,swizzler) ->
  b64 = raw.toString 'base64'
  swizzler or= (x) -> x
  b58 = swizzler armorx.encoding.b58.encoding.encode raw
  raw2 = armorx.encoding.b58.encoding.decode b58
  b64_2 = raw2.toString('base64')
  T.equal b64, b64_2, nm

exports.test_bad_alphabet = (T,cb) ->
  err = null
  try
    x = new armorx.encoding.Encoding "a", 0
  catch e
    err = e
  T.assert err?, "should have hit an error"
  cb()

exports.test_empty = (T,cb) ->
  test T, "empty", new Buffer []
  cb()

exports.test_randoms_1 = (T,cb) ->
  for i in [1...100]
    for j in [0...20]
      b = prng(i)
      nm = "rand_#{i}_#{j}"
      test T, nm, b
  cb()

exports.test_zero_pad_1 = (T,cb) ->
  for i in [1...30]
    for j in [0..i]
      for k in [0...3]
        b = new Buffer (0 for l in [0...j] )
        b = Buffer.concat [ b, prng(i-j) ]
        nm = "zero_pad_#{i}_#{j}_#{k}"
        test T, nm, b
        break if i is j
  cb()

junk_sequence = (prob) ->
  badch = " !@#$%^&&*())_+-={}[]:;'<>?,./~`\n\r0"
  (badch[i%badch.length] while (i = prng(1)[0])/256 < prob).join ''

junk_inserter = (prob) -> (s) -> (c + junk_sequence(prob) for c in s).join ''

exports.junk_insertion = (T,cb) ->
  for i in [10...100] by 3
    for j in [5...50]
      b = prng(i)
      nm = "junk_insert_#{i}_#{j}"
      test T, nm, b, junk_inserter(j/100)
  cb()

exports.encoded_len = (T,cb) ->
  el = armorx.encoding.b58.encoding.encoded_len 19*2
  T.equal el, 26*2, "right encoding length"
  cb()

exports.decoded_len = (T,cb) ->
  dl = armorx.encoding.b58.encoding.decoded_len 26*2
  T.equal dl, 19*2, "right decoding length"
  cb()
