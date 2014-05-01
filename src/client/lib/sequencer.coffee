LATENCY = Meteor.settings.latency || 1

class ImplSequencer
  constructor: ->
    @_buffers = {}
    @_ctx = getAudioContext()
    @_enabled = false
    @_sources = []

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
    nextBeat = Metronome.getNextBeat()

    Utterances.find().forEach (utterance) =>
      start = nextBeat + utterance.offset
      if (buffer = @_buffers[utterance._id])
        source = @_ctx.createBufferSource()
        source.buffer = buffer
        source.connect @_ctx.destination
        source.start start, 0, utterance.duration
        @_sources.push source

      Utterances.update utterance._id,
        $set:
          playbackStart: start
          playbackEnd: start + utterance.duration

  stop: ->
    throw 'Sequencer is disabled' unless @_enabled
    for source in @_sources
      source.stop()
    @_sources = []
    return

sequencer = null

getSequencer = ->
  sequencer ||= new ImplSequencer

class @Sequencer
  @enable: ->
    getSequencer().enable()

  @disable: ->
    getSequencer().disable()

  @play: ->
    getSequencer().play()

  @stop: ->
    getSequencer().stop()

