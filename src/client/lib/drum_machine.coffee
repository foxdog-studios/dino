class @DrumMachine
  constructor: (pattern) ->
    check pattern, [[Match.Integer]]
    @setPattern(pattern)
    @kickSynth = new NoiseSynth()
    @snareSynth = new NoiseSynth(1)

  setPattern: (pattern) ->
    check pattern, [[Match.Integer]]
    @pattern = pattern

  start: ->
    @computation = Deps.autorun =>
      nextBeat = Metronome.getNextBeat()
      @playPatternAtBeat(nextBeat)

  stop: ->
    if @computation?
      @computation.stop()

  playPatternAtBeat: (nextBeat) ->
    for track in @pattern
      beatOfBar = nextBeat.getBeatOfBar()
      state = track[beatOfBar]
      synth = switch state
        when 1
          @kickSynth
        when 2
          @snareSynth
      if synth?
        synth.start(nextBeat.time, 1 / 10)


