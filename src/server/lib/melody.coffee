class Melody
  class ImplMelody
    constructor: (notes) ->
      @_numNotes = notes.length
      @_unassigned = notes

    assignAtMost: (numNotes) ->
      @_unassigned.splice 0, numNotes

    getNumNotes: ->
      @_numNotes

    getNumUnassignedNotes: ->
      @_unassigned.length

    transpose: (semitones) ->
      @_unassigned = _.map @_unassigned, (note) ->
        note.transpose semitones

  @parse = (bpm, rawMelody) ->
    nextStart = 0
    rawNotes = rawMelody.trim().split /\s+/

    notes =
      for rawNote in rawNotes
        note = NoteParser.parse(rawNote).schedule bpm, nextStart
        nextStart += note.getDuration()
        continue if note.isRest()
        note

    new ImplMelody notes

@getMelody = _.once ->
  track = Meteor.settings.public.track
  melody = Melody.parse track.bpm, track.melody.join ' '
  if (semitones = track.transpose)?
    melody.transpose semitones
  melody
