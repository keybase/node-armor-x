stream = require('keybase-chunk-stream')

exports.StreamEncoder = class StreamEncoder extends stream.ChunkStream
  constructor : (@encoder) ->
    f = (x) => @encoder.encode(x)
    super({transform_func : f, block_size : @encoder.in_block_len, exact_chunking : false, writableObjectMode : false, readableObjectMode : false})

exports.StreamDecoder = class StreamDecoder extends stream.ChunkStream
  constructor : (@decoder) ->
    f = (x) => @decoder.decode(x)
    super({transform_func : f, block_size : @decoder.out_block_len, exact_chunking : false, writableObjectMode : false, readableObjectMode : false})
