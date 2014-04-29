Meteor.startup ->
  reset()

Meteor.methods
  reset: ->
    reset()

reset = ->
  # Teardown
  Meteor.users.remove {}
  Utterances.remove {}

  # Setup
  track = Meteor.settings.public.track
  Melody.reset parseMelody track.bpm, track.melody.join ' '
  Melody.transpose track?.transpose || 0

  return

