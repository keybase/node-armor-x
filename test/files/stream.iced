crypto = require('crypto')
stream = require('../../src/stream.iced')
to_buffer = require ('../../src/stream_to_buffer.iced')
enc = require('../../src/encoding.iced')

#==========================================================
#Helper functions/constants
#==========================================================

loop_limit = 5000
# some random-ish large-ish prime
loop_skip = 271
bases = [58, 62, 64]

encoding_for_base = (base) ->
  switch base
    when 58 then enc.b58.encoding
    when 62 then enc.b62.encoding
    when 64 then enc.b64.encoding

# writes random data in random chunk sizes to the given stream
stream_random_data = (strm, len, cb) ->
  written = 0
  expected_results = []
  while written < len
    # generate random length
    await crypto.randomBytes(1, defer(err, index))
    if err then throw err
    amt = (index[0] + 1)*16

    # generate random bytes of length amt
    await crypto.randomBytes(amt, defer(err, buf))
    if err then throw err
    written += buf.length
    expected_results.push(buf)

    # write the buffer
    await strm.write(buf, defer(err))
    if err then throw err

  cb(Buffer.concat(expected_results))

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

  await stream_random_data(encoder, len, defer(data))
  await
    stb.on('finish', defer())
    encoder.end()

  decoded_data = stb.getBuffer()

  T.equal(data, decoded_data, "inconsistency found: base=#{base} len=#{len}")

#encode, compare against a known good encoding function
test_bx_output = (T, base, len) ->
  encoding = encoding_for_base(base)
  encoder = new stream.StreamEncoder(encoding)
  stb = new to_buffer.StreamToBuffer()

  encoder.pipe(stb)

  await stream_random_data(encoder, len, defer(data))
  await
    stb.on('finish', defer())
    encoder.end()

  stock = new Buffer(encoding.encode(data))
  encoded_data = stb.getBuffer()

  T.equal(stock, encoded_data, "bad output found: base=#{base} len=#{len}")

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
  T.equal(new Buffer('0SAPP'), stb.getBuffer(), 'Not foo on encode!')
  decoder = new stream.StreamDecoder(enc.b62.encoding)
  stb = new to_buffer.StreamToBuffer()
  decoder.pipe(stb)
  decoder.write('0SAPP')
  decoder.end()
  T.equal(new Buffer('foo'), stb.getBuffer(), 'Not foo on decode!')
  cb()
