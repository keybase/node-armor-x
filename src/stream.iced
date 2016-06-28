stream = require('stream');
enc = require('./encoding');

exports.Streamer = class Streamer extends stream.Duplex

	constructor : (block_len) ->
		alphabet = enc.b58.alphabet if block_len is 58
		alphabet = enc.b62.alphabet if block_len is 58
		alphabet = enc.b64.alphabet if block_len is 58
		@encoder = new Encoding(alphabet, block_len);
		super({highWaterMark: block_len});

	encode : (src) ->
		src.on('readable', () ->
			chunk = null;
			while (chunk = src.read(@highWaterMark)) != null
				@write enc.b64.encoding.encode(chunk);
			)

	decode : (src) ->
		src.on('readable', () ->
			chunk = null;
			while (chunk = src.read(@highWaterMark)) != null
				@write(enc.b64.encoding.decode(chunk));
			)
