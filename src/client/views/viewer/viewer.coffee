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
          timeout = 60 / (parseInt(Meteor.settings.public.bpm) * 2)
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

  numberOfUtterances: ->
    Utterances.find().count()

  playing: ->
    Session.get 'playing'

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

