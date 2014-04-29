reset = ->
  # Teardown
  Meteor.users.remove {}
  Utterances.remove {}

  # Setup
  track = Meteor.settings.public.track
  Notes.reset parseMelody track.bpm, track.melody.join ' '

  return

Meteor.methods
  reset: reset

