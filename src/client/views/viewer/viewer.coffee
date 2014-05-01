DINO_SCHEMA =
  baby:
    sound: 'baby'
    image: '/baby.gif'
  kid:
    sound: 'kid'
    image: '/kid.gif'
  fat:
    sound: 'fat'
    image: '/fat.gif'
  final:
    sound: 'final'
    image: '/final.gif'

Template.viewer.rendered = ->
  Metronome.enable()
  Sequencer.enable()

  Session.set 'playing', false
  @_keyupHandler = (event) ->
    switch event.which
      when KeyCodes.SPACE
        event.preventDefault()
        if (isPlaying = Session.get 'playing')
          Sequencer.stop()
        else
          Sequencer.play()
        Session.set 'playing', not isPlaying
      when KeyCodes.R
        event.preventDefault()
        Methods.reset()
  window.addEventListener 'keydown', @_keyupHandler, false

Template.viewer.helpers
  utterances: ->
    return unless (nextUtterance = getNextUtterance())
    Utterances.find
      messageId: nextUtterance.messageId
    ,
      sort:
        playbackStart: 1

  info: ->
    Meteor.settings.public.info

  numberOfUtterances: ->
    Utterances.find().count()

  progress: ->
    getProgress().toFixed(1)

  playing: ->
    Session.get 'playing'

  hasEnoughWords: ->
    getProgress() >= 100

  dino: ->
    progress = getProgress()
    name = switch
      when progress <  33 then 'baby'
      when progress <  66 then 'kid'
      when progress < 100 then 'fat'
      else 'final'
    dino = DINO_SCHEMA[name]
    dino.progress = progress
    # Don't play at beginning
    if progress > 0
      getSfx().play(dino.sound)
    dino

Template.viewer.destroyed = ->
  window.removeEventListener 'keydown', @_keyupHandler, false
  delete @_keyupHandler
  Session.set 'playing'
  Sequencer.disable()
  Metronome.disable()

getNextUtterance = ->
  nextBeat = Metronome.getNextBeat()
  Utterances.findOne
    playbackStart:
      $lte: nextBeat.now
    playbackEnd:
      $gt: nextBeat.now
  ,
    sort:
      playbackStart: 1

@getProgress = ->
  progress = Progress.findOne()
  return 0 unless progress
  progress.progress


