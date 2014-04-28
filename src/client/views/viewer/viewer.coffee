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
          requestAnimationFrame(updateTime)
      updateTime()


Template.viewer.helpers
  utterances: ->
    Utterances.find
      playbackStart:
        $gt: Session.get('currentTime')

  playing: ->
    Session.get 'playing'

Template.viewer.destroyed = ->
  window.removeEventListener 'keyup', @_keyupHandler, false
  delete @_keyupHandler
  Session.set 'playing'
  Sequencer.disable()

