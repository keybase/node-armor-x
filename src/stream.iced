stream = require('keybase-chunk-stream')

exports.StreamEncoder = class StreamEncoder extends stream.ChunkStream
  constructor : (@encoder) ->
    f = (x) => @encoder.encode(x)
    super(f, @encoder.in_block_len, false)

exports.StreamDecoder = class StreamDecoder extends stream.ChunkStream
  constructor : (@decoder) ->
    f = (x) => @decoder.decode(x)
    super(f, @decoder.out_block_len, false)
