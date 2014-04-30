class @NoiseSynth
  @GAIN = 3.5

  constructor: (gain=NoiseSynth.GAIN) ->
    lastOut = 0.0
    @ctx = getAudioContext()
    # Fill 2 seconds of noise
    bufferSize = 2 * @ctx.sampleRate
    @noiseBuffer = @ctx.createBuffer(1, bufferSize, @ctx.sampleRate)
    output = @noiseBuffer.getChannelData(0)
    for i in [0...bufferSize]
      white = Math.random() * 2 - 1
      output[i] = (lastOut + (0.02 * white)) / 1.02
      lastOut = output[i]
      output[i] *= gain

  start: (start, length) ->
    check start, Number
    check length, Number
    @node = @ctx.createBufferSource()
    @node.buffer = @noiseBuffer
    @node.loop = true
    @node.start start
    @node.stop start + length
    @node.connect @ctx.destination

