http = require 'http';

server = http.createServer((req, res) ->
	req.setEncoding('utf8');
	req.on('data', (chunk) ->
		res.write(chunk);
	)
	req.on('end', () ->
		res.write("End stream");
		res.end();
	)
)

server.listen(39393);
