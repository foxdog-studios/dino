class ImplMelody
  constructor: ->
    @_isLocked = false
    @_numNotes = 0
    @_remaining = []

  _aquire: ->
    if @_isLocked
      throw 'Cannot aquire lock, it is already aquired.'
    @_isLocked = true

  _release: ->
    unless @_isLocked
      throw 'Cannot release lock, it has already been released.'
    @_isLocked = false

  _withLock: (func) ->
    @_aquire()
    result = func()
    @_release()
    result

  _checkMaxNotes: (maxNotes) ->
    check maxNotes, Number

  _cloneNotes: (notes) ->
    _.clone notes

  reset: (notes) ->
    @_withLock =>
      @_numNotes = notes.length
      @_remaining = @_cloneNotes notes

  assign: (maxNotes) ->
    @_checkMaxNotes maxNotes
    @_withLock =>
      @_remaining.splice 0, maxNotes

  numNotes: ->
    @_withLock =>
      @_numNotes

  numRemaining: ->
    @_withLock =>
      @_remaining.length

  transpose: (semitones) ->
    check semitones, Number
    @_withLock =>
      @_remaining = for note in @_remaining
        note.transpose semitones

melody = null

getMelody = ->
  melody ||= new ImplMelody

class @Melody
  @reset: (notes) ->
    getMelody().reset notes

  @assign: (maxNotes) ->
    getMelody().assign maxNotes

  @numNotes: ->
    getMelody().numNotes()

  @numRemaining: ->
    getMelody().numRemaining()

  @transpose: (semitones) ->
    getMelody().transpose semitones

@parseMelody = (bpm, rawMelody) ->
  # Seconds per beat
  nextStart = 0

  # Leading or trailing whitespace creates an empty raw notes when
  # split.
  rawMelody = rawMelody.trim()

  for rawNote in rawMelody.split /\s+/
    note = NoteParser.parse(rawNote).schedule bpm, nextStart
    nextStart += note.getDuration()
    continue if note.isRest()
    note

