DINO_SCHEMA =
  baby:
    sound: 'baby'
    image: '/dino.gif'
  fat:
    sound: 'fat'
    image: '/fatterdino.gif'
  teenager:
    sound: 'teenager'
    image: '/teenagedino.gif'
  final:
    sound: 'final'
    image: '/finaldino.gif'

Template.viewer.rendered = ->
  Metronome.enable()
  Sequencer.enable()

  drumMachine = new DrumMachine(Meteor.settings.public.track.drumPattern,
                                Meteor.settings.public.track.drumVolume)

  Session.set 'playing', false
  @_keyupHandler = (event) ->
    switch event.keyCode
      when KeyCode.SPACE
        event.preventDefault()
        if (isPlaying = Session.get 'playing')
          Sequencer.stop()
        else
          Sequencer.play()
        Session.set 'playing', not isPlaying
      when KeyCode.D
        event.preventDefault()
        if (isDrumming = Session.get 'drumming')
          drumMachine.stop()
        else
          drumMachine.start()
        Session.set 'drumming', not isDrumming
      when KeyCode.R
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
      when progress <  66 then 'teenager'
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


