{prng} = require('crypto')
stream = require('../../src/stream.iced')
enc = require('../../src/encoding.iced')
b58enc = enc.b58
b62enc = enc.b62
b64enc = enc.b64

b64stripped =
  encode : (x) ->
    r = new RegExp('=', 'g')
    x.toString('base64').replace(r, '')
  decode : (x) ->
    until (x.length % 4) is 0
      x += "="
    return new Buffer x, 'base64'

#==========================================================
#These tests encode then immediately decode, and compare the result to the original text
#=========================================================

exports.test_b58_consistency = (T, cb) ->

  for i in [1...5000] by 17
    encoder = new stream.StreamEncoder(b58enc.encoding)
    decoder = new stream.StreamDecoder(b58enc.encoding)
    encoder.pipe(decoder)

    data = prng(i)
    encoder.write(data)
    decoded_data = decoder.read()

    T.equal(data, decoded_data, "inconsistency found: data=#{data}")
  cb()

exports.test_b62_consistency = (T, cb) ->

  for i in [1...5000] by 17
    encoder = new stream.StreamEncoder(b62enc.encoding)
    decoder = new stream.StreamDecoder(b62enc.encoding)
    encoder.pipe(decoder)

    data = prng(i)
    encoder.write(data)
    decoded_data = decoder.read()

    T.equal(data, decoded_data, "inconsistency found: data=#{data}")
  cb()

exports.test_b64_consistency = (T, cb) ->

  for i in [1...5000] by 17
    encoder = new stream.StreamEncoder(b64enc.encoding)
    decoder = new stream.StreamDecoder(b64enc.encoding)
    encoder.pipe(decoder)

    data = prng(i)
    encoder.write(data)
    decoded_data = decoder.read()

    T.equal(data, decoded_data, "inconsistency found: data=#{data}")
  cb()

#=========================================================
#These tests check whether or not the encoding is valid
#=========================================================

exports.test_b64_output = (T, cb) ->

  for i in [1...5000] by 17
    encoder = new stream.StreamEncoder(b64enc.encoding)

    data = prng(i)
    stock = b64stripped.encode(data)

    encoder.write(data)
    encoded_data = encoder.read().toString()

    T.equal(stock, encoded_data, "inconsistency found: data=#{data}")
  cb()

#==========================================================
#These tests check the consistency and output of a very very large file
#==========================================================

exports.test_giant_file_consistency = (T, cb) ->
  encoder = new stream.StreamEncoder(b64enc.encoding)
  decoder = new stream.StreamDecoder(b64enc.encoding)
  encoder.pipe(decoder)
  data = prng(1000000)

  encoder.write(data)
  decoded_data = decoder.read()

  T.equal(data, decoded_data, "inconsistency found: data=#{data}")
  cb()

exports.test_giant_file_output = (T, cb) ->
  encoder = new stream.StreamEncoder(b64enc.encoding)
  data = prng(1000000)
  stock = b64stripped.encode(data)

  encoder.write(data)
  encoded_data = encoder.read().toString()

  T.equal(stock, encoded_data, "inconsistency found: data=#{data}")
  cb()
