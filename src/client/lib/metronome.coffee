class Beat
  constructor: (@time, @beatsSinceStart, @beatsInBar, @secondsPerBeat, @now) ->

  getBeatOfBar: ->
    @beatsSinceStart % Meteor.settings.public.track.beatsPerBar

  getNextBeatAt: (beatOfBar) ->
    currentBeatOfBar = @getBeatOfBar()
    if currentBeatOfBar > beatOfBar
      beatOfBar += @beatsInBar
    difference = beatOfBar - currentBeatOfBar
    differenceSeconds = difference * @secondsPerBeat
    beatTime = @time + differenceSeconds
    beatsSinceStart = @beatsSinceStart + difference
    new Beat(beatTime, beatsSinceStart, @beatsInBar, @secondsPerBeat,
             @now + differenceSeconds)

class ImplMetronome
  constructor: ->
    @_callback = _.bind @_updateNextBeat, this
    @_nextBeatDependency = new Deps.Dependency
    @_nextBeat = null

  _getInterval: ->
    # Two updates per beat (Nyquist's theorem).
    (60 * 1000) / (@_getBpm() * 2)

  _getCurrentTime: ->
    getAudioContext().currentTime

  _getBpm: ->
    Meteor.settings.public.track.bpm

  _getBeatsInBar: ->
    Meteor.settings.public.track.beatsPerBar

  _getSecondsPerBeat: ->
    60 / @_getBpm()

  _getSecondsSinceStart: ->
    @_getCurrentTime()

  _getBeatsSinceStart: ->
    @_getSecondsSinceStart() / @_getSecondsPerBeat()

  _getNextBeat: ->
    Math.ceil(@_getBeatsSinceStart())

  _getNextBeatTime: ->
    @_getNextBeat() * @_getSecondsPerBeat()

  _updateNextBeat: ->
    nextBeatTime = @_getNextBeatTime()
    return if @_nextBeat?.time == nextBeatTime
    @_nextBeat = new Beat(nextBeatTime,
                          @_getNextBeat(),
                          @_getBeatsInBar(),
                          @_getSecondsPerBeat(),
                          @_getCurrentTime())
    @_nextBeatDependency.changed()

  _isEnabled: ->
    @_timeoutId?

  _isDisabled: ->
    not @_isEnabled()

  enable: ->
    return if @_isEnabled()
    @_updateNextBeat()
    @_timeoutId = Meteor.setInterval @_callback, @_getInterval()
    return

  disable: ->
    return if @_isDisabled()
    Meteor.clearTimeout @_timeoutId
    delete @_timeoutId
    return

  _assertEnabled: ->
    throw 'Metronome is disabled' if @_isDisabled()

  getNextBeat: ->
    @_assertEnabled()
    @_nextBeatDependency.depend()
    @_nextBeat

metronome = null

getMetronome = ->
  metronome ||= new ImplMetronome

class @Metronome
  @enable: ->
    getMetronome().enable()

  @disable: ->
    getMetronome().disable()

  @getNextBeat: ->
    getMetronome().getNextBeat()

