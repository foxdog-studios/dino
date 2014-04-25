reset = ->
  # Teardown
  Meteor.users.remove {}
  Notes.remove {}
  Utterances.remove {}

  # Setup
  track = Meteor.settings.track
  notes = parseMelody track.bpm, track.melody.join ' '
  for note in notes
    Notes.insert note

  return

Meteor.methods
  reset: reset

