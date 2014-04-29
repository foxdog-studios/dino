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

class @KeyCode
  @SPACE: 32
  @R: 82

Template.viewer.rendered = ->
  Sequencer.enable()
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
      when KeyCode.R
        event.preventDefault()
        Methods.reset()
  window.addEventListener 'keydown', @_keyupHandler, false

  Deps.autorun ->
    playing = Session.get 'playing'
    if playing
      updateTime = ->
        Session.set('currentTime', new Date().getTime())
        playing = Session.get 'playing'
        if playing
          # Check at twice the bpm (nyquist's theorem)
          timeout = 60 / (Meteor.settings.public.track.bpm * 2)
          Meteor.setTimeout updateTime, timeout
      updateTime()


Template.viewer.helpers
  utterances: ->
    currentTime = Session.get('currentTime')
    options =
      sort:
        playbackStart: 1
    nextUtterance = Utterances.findOne
        playbackStart:
          $lte: currentTime
        playbackEnd:
          $gt: currentTime
      , options
    return unless nextUtterance?
    Utterances.find(messageId: nextUtterance.messageId, options)

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
    if progress > 0 and not Session.get('playing')
      SFX.play(dino.sound)
    dino

@getProgress = ->
  progress = Progress.findOne()
  return 0 unless progress
  progress.progress

Template.utterance.helpers
  currentUtterance: ->
    currentTime = Session.get('currentTime')
    nextUtterance = Utterances.findOne
        playbackStart:
          $lte: currentTime
        playbackEnd:
          $gt: currentTime
      ,
        sort:
          playbackStart: 1
    return unless nextUtterance?
    if nextUtterance._id == @_id
      'current-utterance'


Template.viewer.destroyed = ->
  window.removeEventListener 'keydown', @_keyupHandler, false
  delete @_keyupHandler
  Session.set 'playing'
  Sequencer.disable()

