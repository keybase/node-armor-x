enc = require './encoding'
http = require('http');
b62 = enc.b62.encoding

stream_data = (src, dst) ->
	src.on 'data', (chunk) ->
		dst.write(b62.encode(new Buffer chunk, 'utf-8'));

server = http.createServer (req, res) ->
	stream_data(req, res);
	req.on 'end', ->
		res.end();

server.listen(1337);
