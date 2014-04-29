reset = ->
  # Teardown
  Meteor.users.remove {}
  Notes.remove {}
  Utterances.remove {}

  # Setup
  track = Meteor.settings.track
  notes = parseMelody Meteor.settings.public.bpm, track.melody.join ' '
  for note in notes
    Notes.insert note

  return

Meteor.methods
  reset: reset

