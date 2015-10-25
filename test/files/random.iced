{prng} = require 'crypto'

a58 = require '../..'

test = (T,nm,raw) ->
  b64 = raw.toString 'base64'
  b58 = a58.encoding.std_encoding.encode raw
  raw2 = a58.encoding.std_encoding.decode b58
  b64_2 = raw2.toString('base64')
  T.equal raw, raw2, "for #{nm}: #{raw} = #{raw2}"

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
