class AudioSample
  constructor: (uri, options) ->
    options = _.defaults (options or {}),
      autoStart: false
      autoStop: false
      gain: 1
      loop: false

    @_autoStart = false
    @_autoStop = options.autoStop
    @_loop = options.loop
    @_ready = false

    @_gain = getAudioContext().createGain()
    @_gain.gain.value = options.gain
    @_gain.connect getAudioContext().destination

    request = new XMLHttpRequest
    request.open 'GET', uri, true
    request.responseType = 'arraybuffer'

    callback = (buffer) => @_setBuffer buffer
    request.onload = ->
      getAudioContext().decodeAudioData request.response, callback

    request.send()

  _setBuffer: (buffer) ->
    @_buffer = buffer
    @_ready = true
    @start() if @_autoStart

  start: (start=0) ->
    unless @_ready
      @_autoStart = true
      return

    @_source.stop() if @_autoStop and @_source
    @_source = getAudioContext().createBufferSource()
    @_source.buffer = @_buffer
    @_source.connect @_gain
    @_source.loop = @_loop
    @_source.start start
    @_autoStart = false

  stop: ->
    return unless @_source
    @_source.stop()
    @_autoStart = false
    delete @_source

class Sfx
  constructor: ->
    load = (name) =>
      this[name] = new AudioSample "/#{ name }.ogg",
        autoStop: true
        gain: Meteor.settings?.public?.dinoVolume or 1

    load 'baby'
    load 'kid'
    load 'fat'
    load 'final'

  play: (name) ->
    @_playing.stop() if @_playing
    @_playing = this[name]
    @_playing.start()

sfx = null

@getSfx = ->
  sfx ||= new Sfx

