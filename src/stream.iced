stream = require('stream')
enc = require('./encoding')

desired_block_size = 4096

exports.StreamEncoder = class StreamEncoder extends stream.Transform

  constructor : (@encoder) ->
    super({highWaterMark : encoder.in_block_len*Math.ceil(desired_block_size/encoder.in_block_len)})

  _transform : (chunk, encoding, callback) ->
    @push(@encoder.encode(chunk))
    callback()

exports.StreamDecoder = class StreamDecoder extends stream.Transform

  constructor : (@encoder) ->
    super({highWaterMark : encoder.in_block_len*Math.ceil(desired_block_size/encoder.out_block_len)})

  _transform : (chunk, encoding, callback) ->
    @push(@encoder.decode(chunk))
    callback()
