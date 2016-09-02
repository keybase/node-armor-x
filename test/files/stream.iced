{make_esc} = require('iced-error')
crypto = require('crypto')
util = require('keybase-chunk-stream').util
basex = require('../..')
stream = basex.stream
enc = basex.encoding

#==========================================================
#Helper functions/constants
#==========================================================

giant_file = 524288
loop_limit = 8192
# some random-ish large-ish prime
loop_skip = 271
bases = [58, 62, 64]

encoding_for_base = (base) ->
  switch base
    when 58 then enc.b58.encoding
    when 62 then enc.b62.encoding
    when 64 then enc.b64.encoding

#==========================================================
#Base-agnostic testing functions
#==========================================================

#encode->decode, compare against original
test_bx_consistency = (T, {base, len}, cb) ->
  esc = make_esc(cb, "Error in consistency testing")
  encoding = encoding_for_base(base)
  encoder = new stream.StreamEncoder(encoding)
  decoder = new stream.StreamDecoder(encoding)
  stb = new util.StreamToBuffer()

  encoder.pipe(decoder).pipe(stb)

  await util.stream_random_data(encoder, len, esc(defer(data)))
  await
    stb.on('finish', defer())
    encoder.end()

  T.equal(data, stb.getBuffer(), "inconsistency found: base=#{base} len=#{len}")
  cb()

#encode, compare against a known good encoding function
test_bx_output = (T, {base, len}, cb) ->
  esc = make_esc(cb, "Error in output testing")
  encoding = encoding_for_base(base)
  encoder = new stream.StreamEncoder(encoding)
  stb = new util.StreamToBuffer()

  encoder.pipe(stb)

  await util.stream_random_data(encoder, len, esc(defer(data)))
  await
    stb.on('finish', defer())
    encoder.end()

  stock = new Buffer(encoding.encode(data))

  T.equal(stock, stb.getBuffer(), "bad output found: base=#{base} len=#{len}")
  cb()

#==========================================================
#These tests encode then immediately decode, and compare the result to the original text
#=========================================================

exports.test_consistency = (T, cb) ->
  start = new Date().getTime()
  for base in bases
    for i in [1...loop_limit] by loop_skip
      await test_bx_consistency(T, {base, len : i}, defer())
  end = new Date().getTime()
  console.log("Time: #{end - start}")
  cb()

#=========================================================
#These tests check whether or not the encoding is valid
#=========================================================

exports.test_output = (T, cb) ->
  start = new Date().getTime()
  for base in bases
    for i in [1...loop_limit] by loop_skip
      await test_bx_output(T, {base, len : i}, defer())
  end = new Date().getTime()
  console.log("Time: #{end - start}")
  cb()

#=========================================================
#These tests try consistency and output for a 200k file
#=========================================================

exports.test_giant_file_consistency = (T, cb) ->
  start = new Date().getTime()
  for base in bases
    await test_bx_consistency(T, {base, len : giant_file}, defer())
  end = new Date().getTime()
  console.log("Time: #{end - start}")
  cb()

exports.test_giant_file_output = (T, cb) ->
  start = new Date().getTime()
  for base in bases
    await test_bx_output(T, {base, len : giant_file}, defer())
  end = new Date().getTime()
  console.log("Time: #{end - start}")
  cb()

exports.test_foo = (T, cb) ->
  encoder = new stream.StreamEncoder(enc.b62.encoding)
  stb = new util.StreamToBuffer()
  encoder.pipe(stb)
  await encoder.write('foo')
  await
    stb.on('end', defer())
    encoder.end()
  T.equal(new Buffer('0SAPP'), stb.getBuffer(), 'Not foo on encode!')

  decoder = new stream.StreamDecoder(enc.b62.encoding)
  stb = new util.StreamToBuffer()
  decoder.pipe(stb)
  decoder.write('0SAPP')
  await
    stb.on('end', defer())
    decoder.end()
  T.equal(new Buffer('foo'), stb.getBuffer(), 'Not foo on decode!')
  cb()
