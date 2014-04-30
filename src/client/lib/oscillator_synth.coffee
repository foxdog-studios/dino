class @OscillatorSynth
  @GAIN = 1

  constructor: (gain=OscillatorSynth.GAIN, @frequency) ->
    @ctx = getAudioContext()
    @gainNode = @ctx.createGain()
    @gainNode.connect(@ctx.destination)
    @gainNode.gain.value = gain

  start: (start, length) ->
    @oscillator = @ctx.createOscillator()
    @oscillator.frequency.value = @frequency
    @oscillator.connect @gainNode
    @oscillator.start start
    @oscillator.stop(start + length)

