{nbv,nbi,BigInteger} = require 'bn'

#=====================================================================

exports.Encoding = class Encoding

  constructor : (@alphabet, @in_block_len) ->
    @base = @alphabet.length
    @base_big = nbv @base
    @log_base = Math.log2(@base)
    @out_block_len = Math.ceil(8 * @in_block_len / @log_base)
    @max_encoded_bits_per_block = Math.floor @log_base * @out_block_len
    @decode_map = {}
    for a,i in (new Buffer @alphabet, 'utf8')
      @decode_map[a] = i

  # encoder a buffer of binary data into a basex-string encoding
  # specifying {old_shift : true} for opts causes the encoding to left-shift extra bits. see https://saltpack.org/armoring#comparison-to-base64
  encode : (src, opts) ->
    if not src? then return new Buffer('')
    if opts?.old_shift then old_shift = opts.old_shift else old_shift = false
    inc = @in_block_len
    (@encode_block(src[i...(i+inc)], old_shift) for _, i in src by inc).join ''

  extra_bits : ({decoded_len, encoded_len}) ->
    # number of bits that can be encoded with the encoded len
    encoded_bits = if encoded_len is @out_block_len then @max_encoded_bits_per_block
    else Math.floor(@log_base * encoded_len)
    # Number of bits that can be encoded with the decoded len
    decoded_bits = decoded_len * 8
    # the junk bits that we should shift away
    encoded_bits - decoded_bits

  # encode a block of length @in_block_len or less....
  encode_block : (block, old_shift) ->
    # This is the minimal number of encoding bytes it takes to
    # output the input block
    encoded_len = @encoded_len block.length
    # The raw big-endian representation of the block
    num = (nbi().fromBuffer block)
    # Left shift away all bits that are always going to be 0
    if old_shift then num = num.shiftLeft(@extra_bits {encoded_len, decoded_len : block.length})

    chars = while num.compareTo(BigInteger.ZERO) > 0
      [num,r] = num.divideAndRemainder @base_big
      @alphabet[r.intValue()]
    chars.reverse()
    padlen = encoded_len - chars.length
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

  # specifying {old_shift : true} for opts causes the decoding to right-shift extra bits. see https://saltpack.org/armoring#comparison-to-base64
  decode : (src, opts) ->
    if not src? then return new Buffer('')
    if opts?.old_shift then old_shift = opts.old_shift else old_shift = false
    src = new Buffer src, 'utf8'
    bufs = while src.length
      [dst,src] = @decode_block src, old_shift
      dst
    Buffer.concat bufs

  decode_block : (src, old_shift) ->
    res = nbv 0
    consumed = 0

    for c,src_p in src when (d = @decode_map[c])?
      res = res.multiply(@base_big).add(nbv(d))
      break if ++consumed is @out_block_len

    ret = if consumed is 0 then new Buffer []
    else
      decoded_len = @decoded_len consumed
      if old_shift then res = res.shiftRight(@extra_bits {encoded_len : consumed, decoded_len})
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

exports.b58 = b58 =
  alphabet : '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz'
  in_block_len : 19
exports.b58.encoding = new Encoding b58.alphabet, b58.in_block_len

#=====================================================================

exports.b62 = b62 =
  alphabet : '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'
  in_block_len : 32
exports.b62.encoding = new Encoding b62.alphabet, b62.in_block_len

#=====================================================================

exports.b64 = b64 =
  alphabet : 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
  in_block_len : 3
exports.b64.encoding = new Encoding b64.alphabet, b64.in_block_len

#=====================================================================
