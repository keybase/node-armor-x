http = require('http')
enc = require('../../src/encoding.iced')
stream = require('../../src/stream.iced')

server = http.createServer((req, res) ->
	encoder = new stream.StreamEncoder(new enc.Encoding(enc.b64.alphabet, enc.b64.in_block_len))
	req.pipe(encoder)
	encoder.pipe(res)
	req.on('end', () ->
		encoder.end()
	)
	encoder.on('end', () ->
		res.end()
	)
)

server.listen(39393)
