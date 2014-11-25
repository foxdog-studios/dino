Template.viewer.rendered = ->
  DinoSequencer.enable()

  Session.set 'playing', false
  @_keyupHandler = (event) ->
    switch event.which
      when KeyCodes.SPACE
        event.preventDefault()
        togglePlaying()
      when KeyCodes.R
        event.preventDefault()
        togglePlaying()
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
      ,
        sort: [['index', 'asc']]


Template.viewer.destroyed = ->
  window.removeEventListener 'keydown', @_keyupHandler, false
  Session.set 'playing'
  DinoSequencer.disable()


getNextUtterance = ->
  tick = DinoMetronome.getTimeAtNextHalfBeat()
  Utterances.findOne
    playbackStart:
      $lte: tick
    playbackEnd:
      $gte: tick
  ,
    sort:
      playbackStart: 1


togglePlaying = ->
  if (isPlaying = Session.get 'playing')
    DinoSequencer.stop()
  else
    DinoSequencer.play()
  Session.set 'playing', not isPlaying

