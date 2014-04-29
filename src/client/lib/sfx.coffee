class AudioSample
  constructor: (uri, options) ->
    options = _.defaults (options or {}),
      loop: false

    @_autostart = false
    @_loop = options.loop
    @_ready = false

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

  start: ->
    if @_ready
      @_source.stop() if @_source?
      @_source = getAudioContext().createBufferSource()
      @_source.buffer = @_buffer
      @_source.connect getAudioContext().destination
      @_source.loop = @_loop
      @_source.start 0
      @_autostart = false
    else
      @_autostart = true

  stop: ->
    return unless @_source?
    @_source.stop()
    @_autostart = false
    delete @_source

class Sfx
  constructor: ->
    create = (name, options) ->
      new AudioSample "/#{ name }.ogg", options
    @baby     = create 'baby'
    @fat      = create 'teenager'
    @melting  = create 'fat', loop: true
    @teenager = create 'kid'
    @final    = create 'final_form'

  play: (name) ->
    if @currentSound?
      @currentSound.stop()
    @currentSound = @[name]
    @currentSound.start()

sfx = null

@getSfx = ->
  sfx ||= new Sfx

