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

Template.viewer.helpers
  utterances: ->
    Utterances.find()

Template.viewer.destroyed = ->
  window.removeEventListener 'keyup', @_keyupHandler, false
  delete @_keyupHandler
  Session.set 'playing'
  Sequencer.disable()

