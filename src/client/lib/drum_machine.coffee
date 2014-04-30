class @DrumMachine
  constructor: (pattern) ->
    check pattern, [[Match.Integer]]
    @setPattern(pattern)
    @bongo = getSfx().bongo
    @bongoMid = getSfx().bongoMid

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
      switch state
        when 1
          @bongo.start(nextBeat.time)
        when 2
          @bongoMid.start(nextBeat.time)

