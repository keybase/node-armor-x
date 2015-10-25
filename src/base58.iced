{nbv,nbi,BigInteger} = require 'bn'

#=====================================================================

exports.Encoding = class Encoding

  constructor : (@alphabet, @in_block_len) ->
    @base = 58
    @base_big = nbv @base
    @log58 = Math.log2(@base)
    @out_block_len = Math.ceil(8 * @in_block_len / @log58)
    if @alphabet.length isnt @base
      throw new Error "Encoder alphabet length must be 58 chars"
    @decode_map = {}
    for a,i in @alphabet
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
    pad = ( @alphabet[0] for i in [0...padlen])
    (pad.concat chars).join ''

  # for the given input len, how long is it when encoded?
  encoded_len : (n) ->
    if n is @in_block_len then @out_block_len
    else
      nblocks = ~~(n / @in_block_len)
      out = nblocks * @out_block_len
      if (rem = n % @in_block_len) > 0
        out += Math.ceil(rem*8/@log58)
      out

#=====================================================================

class Foo

  decode: (str) ->
    num = BigInteger.ZERO
    base = BigInteger.ONE
    i = 0
    for c,i in str
      break unless c is @alphabet[0]
    start = i
    pad = new Buffer (0 for i in [0...start])
    for c,i in str[start...] by -1
      unless (char_index = @lookup[c])?
        throw new Error('Value passed is not a valid BaseX string.')
      num = num.add base.multiply nbv char_index
      base = base.multiply @basebn
    Buffer.concat [pad, new Buffer(num.toByteArray()) ]

#=====================================================================

exports.std_alphabet = std_alphabet = '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz'
exports.std_encoding = std_encoding = new Encoding std_alphabet, 19

#=====================================================================

console.log std_encoding.encode new Buffer [0...300]