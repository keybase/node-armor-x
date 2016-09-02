stream = require('keybase-chunk-stream')

exports.StreamEncoder = class StreamEncoder extends stream.ChunkStream
  constructor : (@encoder) ->
    # TODO: handle errors from the decoder
    f = (x, cb) => cb(null, new Buffer(@encoder.encode(x)))
    super({transform_func : f, block_size : @encoder.in_block_len, readableObjectMode : false})

exports.StreamDecoder = class StreamDecoder extends stream.ChunkStream
  constructor : (@decoder) ->
    f = (x, cb) => cb(null, new Buffer(@decoder.decode(x)))
    super({transform_func : f, block_size : @decoder.out_block_len, readableObjectMode : false})
