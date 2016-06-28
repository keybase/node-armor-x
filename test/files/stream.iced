stream = require('../../src/stream.iced')
enc = require('../../src/encoding.iced')
b64enc = enc.b64

b64stripped =
	encode : (x) ->
		r = new RegExp('=', 'g')
		x.toString('base64').replace(r, '')
	decode : (x) ->
		until (x.length % 4) is 0
			x += "="
		return new Buffer x, 'base64'

exports.test_b64_consistency = (T, cb) ->
	encoder = new stream.StreamEncoder(new enc.Encoding(b64enc.alphabet, b64enc.in_block_len))
	decoder = new stream.StreamDecoder(new enc.Encoding(b64enc.alphabet, b64enc.out_blocK_len))

	encoder.pipe(decoder)
	for i in [0...10]
		data_string = ''
		for j in [0...i]
			data_string += Math.floor(Math.random()*10)
		console.log(data_string)
		data = new Buffer(data_string)
		encoder.write(data)
		decoded_data = decoder.read()
		T.equal(data, decoded_data, "inconsistency found: data=#{data}")
	cb()
