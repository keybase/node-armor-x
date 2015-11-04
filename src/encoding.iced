{nbv,nbi,BigInteger} = require 'bn'

#=====================================================================

exports.Encoding = class Encoding

  constructor : (@alphabet, @in_block_len) ->
    @base = @alphabet.length
    @base_big = nbv @base
    @log_base = Math.log2(@base)
    @out_block_len = Math.ceil(8 * @in_block_len / @log_base)
    @decode_map = {}
    for a,i in (new Buffer @alphabet, 'utf8')
      @decode_map[a] = i

  # encoder a buffer of binary data into a base58-string encoding
  encode : (src) ->
    inc = @in_block_len
    (@encode_block(src[i...(i+inc)]) for _, i in src by inc).join ''

  # encode a block of length @in_block_len or less....
  encode_block : (block) ->
    num = nbi().fromBuffer block
    chars = while num.compareTo(BigInteger.ZERO) > 0
      [num,r] = num.divideAndRemainder @base_big
      @alphabet[r.intValue()]
    chars.reverse()
    padlen = @encoded_len(block.length) - chars.length
    pad = ( @alphabet[0] for i in [0...padlen] by 1)
    (pad.concat chars).join ''

  # for the given input len, how long is it when encoded?
  encoded_len : (n) ->
    if n is @in_block_len then @out_block_len
    else
      nblocks = ~~(n / @in_block_len)
      out = nblocks * @out_block_len
      if (rem = n % @in_block_len) > 0
        out += Math.ceil(rem*8/@log_base)
      out

  decode : (src) ->
    src = new Buffer src, 'utf8'
    bufs = while src.length
      [dst,src] = @decode_block src
      dst
    Buffer.concat bufs

  decode_block : (src) ->
    res = nbv 0
    consumed = 0
    for c,src_p in src when (d = @decode_map[c])?
      res = res.multiply(@base_big).add(nbv(d))
      break if ++consumed is @out_block_len
    ret = if consumed is 0 then new Buffer []
    else
      res = new Buffer res.toByteArray()
      padlen = @decoded_len(consumed) - res.length
      pad = new Buffer (0 for i in [0...padlen] by 1)
      Buffer.concat [pad, res]
    [ ret, src[(src_p+1)...] ]

  decoded_len : (n) ->
    if n is @out_block_len then @in_block_len
    else
      nblocks = ~~(n / @out_block_len)
      out = nblocks * @in_block_len
      if (rem = n % @out_block_len) > 0
        out += Math.floor(rem * @log_base/ 8 )
      out

#=====================================================================

exports.std_alphabet = std_alphabet = '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz'
exports.std_encoding = std_encoding = new Encoding std_alphabet, 19

#=====================================================================
