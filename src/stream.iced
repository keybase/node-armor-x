stream = require('stream')
enc = require('./encoding')

desired_high_water_mark = 4096
calculate_high_water_mark = (input_length) ->
  input_length*Math.floor(desired_high_water_mark/input_length)

exports.StreamEncoder = class StreamEncoder extends stream.Transform

  constructor : (@encoder) ->
    @extra = null
    @block_size = @encoder.in_block_len
    super({highWaterMark : calculate_high_water_mark(@block_size)})

  _transform : (chunk, encoding, cb) ->
    if @extra
      chunk = Buffer.concat([@extra, chunk])
      @extra = null

    remainder = chunk.length % @block_size
    if remainder isnt 0
      @extra = chunk.slice(chunk.length-remainder)
      chunk = chunk.slice(0, chunk.length-remainder)

    @push(@encoder.encode(chunk))
    cb()

  _flush : (cb) ->
    if @extra then @push(@encoder.encode(extra))
    cb()

exports.StreamDecoder = class StreamDecoder extends stream.Transform

  constructor : (@decoder) ->
    @extra = null
    @block_size = @decoder.out_block_len
    super({highWaterMark : calculate_high_water_mark(@block_size)})

  _transform : (chunk, encoding, cb) ->
    if @extra
      chunk = Buffer.concat([@extra, chunk])
      @extra = null

    remainder = chunk.length % @block_size
    if remainder isnt 0
      @extra = chunk.slice(chunk.length-remainder)
      chunk = chunk.slice(0, chunk.length-remainder)

    @push(@decoder.decode(chunk))
    cb()

  _flush : (cb) ->
    if @extra then @push(@decoder.decode(extra))
    cb()
