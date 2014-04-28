class @KeyCode
  @SPACE: 32

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
        Session.set 'playing', !isPlaying
  window.addEventListener 'keyup', @_keyupHandler, false

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
    Utterances.find()

  playing: ->
    Session.get 'playing'

Template.utterance.helpers
  currentUtterance: ->
    currentTime = Session.get('currentTime')
    nextUtterance = Utterances.findOne
        playbackStart:
          $lt: currentTime
        playbackEnd:
          $gt: currentTime
      ,
        sort:
          playbackStart: 1
    return unless nextUtterance?
    if nextUtterance._id == @_id
      'current-utterance'


Template.viewer.destroyed = ->
  window.removeEventListener 'keyup', @_keyupHandler, false
  delete @_keyupHandler
  Session.set 'playing'
  Sequencer.disable()

