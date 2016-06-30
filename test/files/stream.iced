{prng} = require('crypto')
stream = require('../../src/stream.iced')
enc = require('../../src/encoding.iced')

#==========================================================
#Helper functions
#==========================================================

loop_limit = 5000
loop_skip = 29

first_different_byte = (buf1, buf2) ->
  limit = if buf1.length < buf2.length then buf1.length else buf2.length
  for i in [0...limit]
    if buf1[i] != buf2[i]
      return i
  return -1

#streams random-length chunks of random data into a stream. returns all data written as a buffer
stream_random_data = (strm, len) ->
  data = prng(len)
  i = 0
  j = 0
  while i < data.length
    j = i + prng(1)[0]
    strm.write(data[i...j])
    i = j
  data

encoding_for_base = (base) ->
  switch base
    when 58 then enc.b58.encoding
    when 62 then enc.b62.encoding
    when 64 then enc.b64.encoding

b64stock =
  encode : (x) ->
    r = new RegExp('=', 'g')
    x.toString('base64').replace(r, '')
  decode : (x) ->
    until (x.length % 4) is 0
      x += "="
    return new Buffer x, 'base64'

#encode->decode, compare against original
test_bx_consistency = (T, base, len) ->
  encoding = encoding_for_base(base)
  encoder = new stream.StreamEncoder(encoding)
  decoder = new stream.StreamDecoder(encoding)

  encoder.pipe(decoder)

  data = stream_random_data(encoder, len)
	decoder.read(0)
  decoded_data = decoder.read()

  T.equal(data, decoded_data, "inconsistency found: base=#{base} len=#{len}")

#encode, compare against a known good encoding function
test_bx_output = (T, base, len, stock_func) ->
  encoding = encoding_for_base(base)
  encoder = new stream.StreamEncoder(encoding)

  data = stream_random_data(encoder, len)
  stock = stock_func(data)
  encoded_data = encoder.read().toString()

  T.equal(stock, encoded_data, "bad output found: base=#{base} len=#{len}")

#test whether the encoder is consuming proper block sizes
test_bx_streaming_correctness = (T, base, len) ->
  encoding = encoding_for_base(base)
  encoder = new stream.StreamEncoder(encoding)
  block_encoder = new stream.StreamEncoder(encoding)

  data = stream_random_data(encoder, len)
  block_encoder.write(data)
  encoded_data = encoder.read()
  block_encoded_data = block_encoder.read()
  fdiff = first_different_byte(encoded_data, block_encoded_data)

  T.equal(encoded_data, block_encoded_data, "max was right: base=#{base} len=#{len} fdiff=#{fdiff}")

#==========================================================
#These tests encode then immediately decode, and compare the result to the original text
#=========================================================

exports.test_b58_consistency = (T, cb) ->
  for i in [1...loop_limit] by loop_skip
    test_bx_consistency(T, 58, i)
  cb()

exports.test_b62_consistency = (T, cb) ->
  for i in [1...loop_limit] by loop_skip
    test_bx_consistency(T, 62, i)
  cb()

exports.test_b64_consistency = (T, cb) ->
  for i in [1...loop_limit] by loop_skip
    test_bx_consistency(T, 64, i)
  cb()


#=========================================================
#These tests check whether or not the encoding is valid
#=========================================================

exports.test_b64_output = (T, cb) ->
  for i in [1...loop_limit] by loop_skip
    test_bx_output(T, 64, i, b64stock.encode)
  cb()

exports.test_b62_streaming_correctness = (T, cb) ->
  for i in [1...loop_limit] by loop_skip
    test_bx_streaming_correctness(T, 62, i)
  cb()
