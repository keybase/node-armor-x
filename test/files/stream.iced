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

	for i in [1...1000]
		encoder = new stream.StreamEncoder(new enc.Encoding(b58enc.alphabet, b58enc.in_block_len))
		decoder = new stream.StreamDecoder(new enc.Encoding(b58enc.alphabet, b58enc.in_block_len))
		encoder.pipe(decoder)

		data_string = ''
		data_string += Math.floor(Math.random()*10) for j in [0...i]

		data = new Buffer(data_string)
		encoder.write(data)
		decoded_data = decoder.read()

		T.equal(data, decoded_data, "inconsistency found: data=#{data}")
	cb()

exports.test_b62_consistency = (T, cb) ->

	for i in [1...1000]
		encoder = new stream.StreamEncoder(new enc.Encoding(b62enc.alphabet, b62enc.in_block_len))
		decoder = new stream.StreamDecoder(new enc.Encoding(b62enc.alphabet, b62enc.in_block_len))
		encoder.pipe(decoder)

		data_string = ''
		data_string += Math.floor(Math.random()*10) for j in [0...i]

		data = new Buffer(data_string)
		encoder.write(data)
		decoded_data = decoder.read()

		T.equal(data, decoded_data, "inconsistency found: data=#{data}")
	cb()

exports.test_b64_consistency = (T, cb) ->

	for i in [1...1000]
		encoder = new stream.StreamEncoder(new enc.Encoding(b64enc.alphabet, b64enc.in_block_len))
		decoder = new stream.StreamDecoder(new enc.Encoding(b64enc.alphabet, b64enc.in_block_len))
		encoder.pipe(decoder)

		data_string = ''
		data_string += Math.floor(Math.random()*10) for j in [0...i]

		data = new Buffer(data_string)
		encoder.write(data)
		decoded_data = decoder.read()

		T.equal(data, decoded_data, "inconsistency found: data=#{data}")
	cb()

#=========================================================
#These tests check whether or not the encoding is valid
#=========================================================

exports.test_b64_output = (T, cb) ->

	for i in [1...1000]
		encoder = new stream.StreamEncoder(new enc.Encoding(b64enc.alphabet, b64enc.in_block_len))

		data_string = ''
		data_string += Math.floor(Math.random()*10) for j in [0...i]
		data = new Buffer(data_string)
		stock = b64stripped.encode(data)

		encoder.write(data)
		encoded_data = encoder.read().toString()

		T.equal(stock, encoded_data, "inconsistency found: data=#{data}")
	cb()

#==========================================================
#These tests check the consistency and output of a very very large file
#==========================================================

exports.test_giant_file_consistency = (T, cb) ->
	encoder = new stream.StreamEncoder(new enc.Encoding(b64enc.alphabet, b64enc.in_block_len))
	decoder = new stream.StreamDecoder(new enc.Encoding(b64enc.alphabet, b64enc.in_block_len))
	encoder.pipe(decoder)
	data_string = ''
	data_string += Math.floor(Math.random()*10) for j in [0...100000]
	data = new Buffer(data_string)

	encoder.write(data)
	decoded_data = decoder.read()

	T.equal(data, decoded_data, "inconsistency found: data=#{data}")
	cb()

exports.test_giant_file_output = (T, cb) ->
	encoder = new stream.StreamEncoder(new enc.Encoding(b64enc.alphabet, b64enc.in_block_len))
	data_string = ''
	data_string += Math.floor(Math.random()*10) for j in [0...100000]
	data = new Buffer(data_string)
	stock = b64stripped.encode(data)

	encoder.write(data)
	encoded_data = encoder.read().toString()

	T.equal(stock, encoded_data, "inconsistency found: data=#{data}")
	cb()
