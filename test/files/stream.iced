{prng} = require('crypto')
stream = require('../../src/stream.iced')
to_buffer = require ('../../src/stream_to_buffer.iced')
enc = require('../../src/encoding.iced')

#==========================================================
#Helper functions/constants
#==========================================================

loop_limit = 5000
loop_skip = 271
bases = [58, 62, 64]

#streams random-length chunks of random data into a stream. returns all data written as a buffer
stream_random_data = (strm, len) ->
  data = prng(len)
  i = 0
  j = 0
  while j < data.length
    j = i + prng(1)[0]
    strm.write(data[i...j])
    i = j
  data

encoding_for_base = (base) ->
  switch base
    when 58 then enc.b58.encoding
    when 62 then enc.b62.encoding
    when 64 then enc.b64.encoding

#==========================================================
#Base-agnostic testing functions
#==========================================================

#encode->decode, compare against original
test_bx_consistency = (T, base, len) ->
  encoding = encoding_for_base(base)
  encoder = new stream.StreamEncoder(encoding)
  decoder = new stream.StreamDecoder(encoding)
  stb = new to_buffer.StreamToBuffer()

  encoder.pipe(decoder)
  decoder.pipe(stb)

  data = stream_random_data(encoder, len)
  encoder.end()
  decoder.end()
  decoded_data = stb.getBuffer()

  T.equal(data, decoded_data, "inconsistency found: base=#{base} len=#{len}")

#encode, compare against a known good encoding function
test_bx_output = (T, base, len) ->
  encoding = encoding_for_base(base)
  encoder = new stream.StreamEncoder(encoding)
  stb = new to_buffer.StreamToBuffer()

  encoder.pipe(stb)

  data = stream_random_data(encoder, len)
  encoder.end()
  stock = new Buffer(encoding.encode(data))
  encoded_data = stb.getBuffer()

  T.equal(stock, encoded_data, "bad output found: base=#{base} len=#{len}")

#test whether the encoder is consuming proper block sizes
test_bx_streaming_correctness = (T, base, len) ->
  encoding = encoding_for_base(base)
  encoder = new stream.StreamEncoder(encoding)
  block_encoder = new stream.StreamEncoder(encoding)
  stb1 = new to_buffer.StreamToBuffer()
  stb2 = new to_buffer.StreamToBuffer()

  encoder.pipe(stb1)
  block_encoder.pipe(stb2)

  data = stream_random_data(encoder, len)
  encoder.end()
  block_encoder.write(data)
  block_encoder.end()
  encoded_data = stb1.getBuffer()
  block_encoded_data = stb2.getBuffer()

  T.equal(encoded_data, block_encoded_data, "incorrect blocking found: base=#{base} len=#{len}")

#==========================================================
#These tests encode then immediately decode, and compare the result to the original text
#=========================================================

exports.test_consistency = (T, cb) ->
  for base in bases
    for i in [1...loop_limit] by loop_skip
      test_bx_consistency(T, base, i)
  cb()

#=========================================================
#These tests check whether or not the encoding is valid
#=========================================================

exports.test_output = (T, cb) ->
  for base in bases
    for i in [1...loop_limit] by loop_skip
      test_bx_output(T, base, i)
  cb()

#=========================================================
#These tests check whether or not the encoder blocks properly
#=========================================================

exports.test_streaming_correctness = (T, cb) ->
  for base in bases
    for i in [1...loop_limit] by loop_skip
      test_bx_streaming_correctness(T, base, i)
  cb()

#=========================================================
#These tests try consistency and output for a 200k file
#=========================================================

exports.test_giant_file_consistency = (T, cb) ->
  for base in bases
    test_bx_consistency(T, base, 200000)
  cb()

exports.test_giant_file_output = (T, cb) ->
  for base in bases
    test_bx_output(T, base, 200000)
  cb()

exports.test_foo = (T, cb) ->
  encoder = new stream.StreamEncoder(enc.b62.encoding)
  stb = new to_buffer.StreamToBuffer()
  encoder.pipe(stb)
  encoder.write('foo')
  encoder.end()
  T.equal(new Buffer('0SAPP'), stb.getBuffer(), "Not foo!")
  cb()
