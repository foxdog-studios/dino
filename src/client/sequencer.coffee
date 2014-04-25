LATENCY = Meteor.settings.latency || 1

class ImplSequencer
  constructor: ->
    @_backingTrack = null
    @_buffers = {}
    @_ctx = new AudioContext
    @_ctxStart = Date.now()
    @_enabled = false
    @_sources = []

    @_loadBackingTrack()

  _loadBackingTrack: ->
    url = Meteor.settings.public.backingTrackUrl
    request = new XMLHttpRequest
    request.open 'GET', url, true
    request.responseType = 'arraybuffer'
    request.onload = =>
      @_ctx.decodeAudioData request.response, (buffer) =>
        @_backingTrack = buffer
    request.send()

  _added: (utterance) ->
    @_buffers[utterance._id] = null
    successCallback = (buffer) =>
      if _.has @_buffers, utterance._id
        @_buffers[utterance._id] = buffer
    errorCallback = ->
      console.log "Failed to decode utterance #{ utterance._id }"
    @_ctx.decodeAudioData utterance.wav.buffer, successCallback, errorCallback

  _changed: (utterance) ->
    @_added utterance

  _removed: (utterance) ->
    delete @_buffers[utterance._id]

  _enableUtteranceObserver: ->
    @_utteranceObserver = Utterances.find().observe
      added: _.bind @_added, this
      changed: _.bind @_changed, this
      removed: _.bind @_removed, this

  _disableUtteranceObserver: ->
    if @_utteranceObserver
      @_utteranceObserver.stop()
      delete @_utteranceObserver

  enable: ->
    return if @_enabled
    @_enabled = true
    @_enableUtteranceObserver()

  disable: ->
    return unless @_enabled
    @stop()
    @_disableUtteranceObserver()
    @_enabled = false

  play: ->
    throw 'Sequencer is disabled' unless @_enabled

    @stop()
    trackStart = @_ctx.currentTime + LATENCY

    sequence = (buffer, offset, duration) =>
      source = @_ctx.createBufferSource()
      source.buffer = buffer
      source.connect @_ctx.destination
      start = trackStart + offset
      source.start start, 0, duration
      @_sources.push source
      start

    schedule = utterances: []

    if @_backingTrack
      start = sequence @_backingTrack, 0, @_backingTrack.duration
      schedule.backingTrack =
        start: @_ctxStart + start
        duration: @_backingTrack.duration

    Utterances.find().forEach (utterance) =>
      if (buffer = @_buffers[utterance._id])
        start = sequence buffer, utterance.offset, utterance.duration
      schedule.utterances.push
        utteranceId: utterance._id
        start: @_ctxStart + start
        duration: utterance.duration

    schedule

  stop: ->
    throw 'Sequencer is disabled' unless @_enabled
    for source in @_sources
      source.stop()
    @_sources = []
    return

sequencer = null

getSequencer = ->
  sequencer = new ImplSequencer unless sequencer
  sequencer

class @Sequencer
  @enable: ->
    getSequencer().enable()

  @disable: ->
    getSequencer().disable()

  @play: ->
    getSequencer().play()

  @stop: ->
    getSequencer().stop()

