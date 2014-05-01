class ImplMetronome
  constructor: ->
    @_nextBeatTimeDependency = new Deps.Dependency

  _getBeatsSinceStart: ->
    @_getCurrentTime() / @_getSecondsPerBeat()

  _getBpm: ->
    Meteor.settings.public.track.bpm

  _getCurrentTime: ->
    getAudioContext().currentTime

  _getNextBeat: ->
    Math.ceil @_getBeatsSinceStart()

  _getNextBeatTime: ->
    @_getNextBeat() * @_getSecondsPerBeat()

  _getSecondsPerBeat: ->
    60 / @_getBpm()

  _updateNextBeatTime: ->
    nextBeatTime = @_getNextBeatTime()
    if @_nextBeatTime != nextBeatTime
      @_nextBeatTime = nextBeatTime
      @_nextBeatTimeDependency.changed()

  getNextBeat: ->
    @_assertEnabled()
    @_nextBeatTimeDependency.depend()
    @_nextBeatTime

  _assertEnabled: ->
    throw 'Metronome is disabled' if @_isDisabled()

  _getInterval: ->
    # Two updates per beat (Nyquist's theorem).
    (60 * 1000) / (@_getBpm() * 2)

  _getCallback: ->
    _.bind @_updateNextBeatTime, this

  _isDisabled: ->
    not @_isEnabled()

  _isEnabled: ->
    @_timeoutId?

  disable: ->
    return if @_isDisabled()
    Meteor.clearTimeout @_timeoutId
    delete @_timeoutId
    return

  enable: ->
    return if @_isEnabled()
    @_updateNextBeatTime()
    @_timeoutId = Meteor.setInterval @_getCallback(), @_getInterval()
    return

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

