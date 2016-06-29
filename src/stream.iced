stream = require('stream')
enc = require('./encoding')

desired_block_size = 4096
calculate_block_size = (input_length) ->
  input_length*Math.floor(desired_block_size/input_length)

exports.StreamEncoder = class StreamEncoder extends stream.Transform

  constructor : (@encoder) ->
    super({highWaterMark : calculate_block_size(encoder.in_block_len)})

  _transform : (chunk, encoding, cb) ->
    @push(@encoder.encode(chunk))
    @read(0)
    cb()

exports.StreamDecoder = class StreamDecoder extends stream.Transform

  constructor : (@encoder) ->
    super({highWaterMark : calculate_block_size(encoder.out_block_len)})

  _transform : (chunk, encoding, cb) ->
    @push(@encoder.decode(chunk))
    @read(0)
    cb()
