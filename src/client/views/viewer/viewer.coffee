Template.viewer.rendered = ->
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
        Meteor.call 'resetLyrics'
  window.addEventListener 'keydown', @_keyupHandler, false

Template.viewer.helpers
  hasEnoughWords: ->
    Progress.get() >= 100

  info: ->
    Meteor.settings?.public?.info

  playing: ->
    Session.get 'playing'

  progress: ->
    Progress.get().toFixed 1

  words: ->
    if (utterance = getNextUtterance())?
      Words.find
        lyricsId: utterance.lyricsId

Template.viewer.destroyed = ->
  window.removeEventListener 'keydown', @_keyupHandler, false
  Session.set 'playing'
  Sequencer.disable()

getNextUtterance = ->
  tick = Metronome.getTimeAtNextHalfBeat()
  Utterances.findOne
    playbackStart:
      $lte: tick
    playbackEnd:
      $gt: tick
  ,
    sort:
      playbackStart: 1

