stream = require('stream');
enc = require('./encoding');

exports.Streamer = class Streamer extends stream.Duplex

	constructor : (base) ->
		encoding = enc.b58 if base is 58
		encoding = enc.b62 if base is 62
		encoding = enc.b64 if base is 64
		console.log('ERRA!') unless encoding?
		@encoder = encoding.encoding
		super({highWaterMark: encoding.in_block_len})

	encode : (src) ->
		src.on('readable', () ->
			chunk = null
			while (chunk = src.read(@highWaterMark)) != null
				@write(@encoder.encode(chunk))
			)

	decode : (src) ->
		src.on('readable', () ->
			chunk = null
			while (chunk = src.read(@highWaterMark)) != null
				@write(@encoder.decode(chunk))
			)
