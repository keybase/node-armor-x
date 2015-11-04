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
    # how many characters we need to emit
    encoded_len = @encoded_len block.length
    pad = new Buffer (0 for [0...(@in_block_len - block.length)] )
    num = nbi().fromBuffer Buffer.concat [ block, pad ]
    console.log num
    chars = for i in [0...@out_block_len]
      [num,r] = num.divideAndRemainder @base_big
      @alphabet[r.intValue()]
    ret = (chars.reverse()[0...encoded_len]).join ''
    ret

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
    console.log src
    for c,src_p in src when (d = @decode_map[c])?
      res = res.multiply(@base_big).add(nbv(d))
      console.log c, d, src_p, res
      break if ++consumed is @out_block_len

    # shift over short blocks
    console.log res
    res = res.multiply(@base_big) for [consumed...@out_block_len]
    console.log res

    padded_len = @decoded_len(consumed)

    ret = if consumed is 0 then new Buffer []
    else
      res = (new Buffer res.toByteArray())[0...padded_len]
      padlen = padded_len - res.length
      pad = new Buffer (0 for i in [0...padlen] by 1)
      Buffer.concat [pad, res]
    [ ret, src[(src_p+1)...] ]

  decoded_len : (n) ->
    if n is @out_block_len then @in_block_len
    else
      nblocks = ~~(n / @out_block_len)
      out = nblocks * @in_block_len
      if (rem = n % @out_block_len) > 0
        out += Math.floor(rem * @log_base / 8 )
      out

#=====================================================================

b58 =
  alphabet : '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz'
  in_block_len : 2
b58.encoding = new Encoding b58.alphabet, b58.in_block_len
exports.b58 = b58

#=====================================================================

b62 =
  alphabet : "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
  in_block_len : 2
b62.encoding = new Encoding b62.alphabet, b62.in_block_len
exports.b62 = b62

#=====================================================================

b64 =
  alphabet : "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
  in_block_len : 3
b64.encoding = new Encoding b64.alphabet, b64.in_block_len
exports.b64 = b64

#=====================================================================

s = new Buffer [244]
a = b62.encoding.encode s
console.log a
console.log (b62.encoding.decode a)


