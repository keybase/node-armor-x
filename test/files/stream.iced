{prng} = require('crypto')
stream = require('../../src/stream.iced')
enc = require('../../src/encoding.iced')

#==========================================================
#Helper functions
#==========================================================

stream_random_data = (strm, len) ->
	data = prng(len)
	while data.length
		i = prng(1)[0]
		strm.write(data[0...j])
		data = data[j...]

encoding_for_base = (base) ->
	switch base
		when 58 enc.b58.encoding
		when 62 enc.b62.encoding
		when 64 enc.b64.encoding

b64stock =
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

test_bx_consistency = (T, cb, base) ->
	encoding = encoding_for_base(base)
  for i in [1...5000] by 11
		encoder = new stream.StreamEncoder(encoding)
		decoder = new stream.StreamDecoder(decoding)

    encoder.pipe(decoder)

		stream_random_data(encoder, i)
    decoded_data = decoder.read()

    T.equal(data, decoded_data, "inconsistency found: data=#{data}")
	cb()

exports.test_b58_consistency = (T, cb) ->
	test_bx_consistency(T, cb, 58)

exports.test_b62_consistency = (T, cb) ->
	test_bx_consistency(T, cb, 62)

exports.test_b64_consistency = (T, cb) ->
	test_bx_consistency(T, cb, 64)

#=========================================================
#These tests check whether or not the encoding is valid
#=========================================================

test_bx_output = (T, cb, base, stock_func) ->
	encoding = encoding_for_base(base)
  for i in [1...5000] by 11
    encoder = new stream.StreamEncoder(b64enc.encoding)

    data = prng(i)
    stock = stock_func(data)

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
