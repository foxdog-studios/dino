class ImplMetronome
  constructor: ->
    @_callback = _.bind @_updateCurrentTime, this
    @_currentTimeDependency = new Deps.Dependency
    @_currentTime = null

  _getInterval: ->
    # Two updates per beat (Nyquist's theorem).
    (60 * 1000) / (Meteor.settings.public.track.bpm * 2)

  _updateCurrentTime: ->
    @_currentTime = Date.now()
    @_currentTimeDependency.changed()

  _isEnabled: ->
    @_timeoutId?

  _isDisabled: ->
    not @_isEnabled()

  enable: ->
    return if @_isEnabled()
    @_timeoutId = Meteor.setInterval @_callback, @_getInterval()
    return

  disable: ->
    return if @_isDisabled()
    Meteor.clearTimeout @_timeoutId
    delete @_timeoutId
    return

  getCurrentTime: ->
    throw 'Metronome is disabled' if @_isDisabled()
    @_currentTimeDependency.depend()
    @_currentTime

metronome = null

getMetronome = ->
  metronome ||= new ImplMetronome

class @Metronome
  @enable: ->
    getMetronome().enable()

  @disable: ->
    getMetronome().disable()

  @getCurrentTime: ->
    getMetronome().getCurrentTime()

