{prng} = require('crypto')
stream = require('../../src/stream.iced')
enc = require('../../src/encoding.iced')

#==========================================================
#Helper functions
#==========================================================

loop_limit = 5000
loop_skip = 11

stream_random_data = (strm, len) ->
	data = prng(len)
	i = 0
	j = 0
	while i < data.length
		j = i + prng(1)[0]
		strm.write(data[i...j])
		i = j
	data

test_bx_consistency = (T, base, len) ->
	encoding = encoding_for_base(base)
	encoder = new stream.StreamEncoder(encoding)
	decoder = new stream.StreamDecoder(encoding)

	encoder.pipe(decoder)

	data = stream_random_data(encoder, len)
	decoded_data = decoder.read()
	leftovers = decoder.read(0)

	T.equal(data, decoded_data, "inconsistency found: base=#{base} len=#{len} leftovers=#{leftovers}")

test_bx_output = (T, base, len, stock_func) ->
	encoding = encoding_for_base(base)
	encoder = new stream.StreamEncoder(encoding)
	data = prng(len)
	stock = stock_func(data)

	encoder.write(data)
	encoded_data = encoder.read().toString()
	leftovers = encoder.read(0)

	T.equal(stock, encoded_data, "bad output found: base=#{base} len=#{len} leftovers=#{leftovers}")

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
