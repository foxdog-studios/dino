class AudioSample
  constructor: (uri, options) ->
    options = _.defaults (options or {}),
      loop: false
      autoStop: true
      gain: 1

    @_autoStart = false
    @_loop = options.loop
    @_autoStop = options.autoStop
    @_ready = false

    @gain = getAudioContext().createGain()
    @gain.gain.value = options.gain
    @gain.connect getAudioContext().destination

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
    @start() if @_autostart

  start: (start=0) ->
    if @_ready
      if @autoStop
        @_source.stop() if @_source?
      @_source = getAudioContext().createBufferSource()
      @_source.buffer = @_buffer
      @_source.connect @gain
      @_source.loop = @_loop
      @_source.start start
      @_autoStart = false
    else
      @_autoStart = true

  stop: ->
    return unless @_source?
    @_source.stop()
    @_autoStart = false
    delete @_source

class Sfx
  constructor: ->
    create = (name, options) ->
      new AudioSample "/#{ name }.ogg", options
    dinoVolume = Meteor.settings.public.dinoVolume
    @baby     = create 'baby',
      gain: dinoVolume
    @fat      = create 'teenager',
      gain: dinoVolume
    @melting  = create 'fat',
      gain: dinoVolume
      loop: true
    @teenager = create 'kid',
      gain: dinoVolume
    @final    = create 'final_form',
      gain: dinoVolume
    @bongo    = create 'bongo',
      autoStop: false
      gain: Meteor.settings.public.track.drumKickVolume
    @bongoMid = create 'bongo-mid',
      autoStop: false
      gain: Meteor.settings.public.track.drumSnareVolume

  play: (name) ->
    if @currentSound?
      @currentSound.stop()
    @currentSound = @[name]
    @currentSound.start()

sfx = null

@getSfx = ->
  sfx ||= new Sfx

