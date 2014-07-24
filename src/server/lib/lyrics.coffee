# ==============================================================================
# = Queue                                                                      =
# ==============================================================================

queue = new PowerQueue
  isPaused: true

# If this the first time dino has been run or the database has been
# reset initialize the notee collection. If it's left empty, the
# application doesn't, it just does nothing and it's very confusing.
queue.add (done) ->
  if Notes.find().count() == 0
    initializeNotes()
  done()

Meteor.startup ->
  queue.run()


# ==============================================================================
# = Notes                                                                      =
# ==============================================================================

@Notes = new Meteor.Collection 'notes'

queueNoteInitialization = ->
  queue.add (done) ->
    initializeNotes()
    done()

initializeNotes = ->
  settings = Meteor.settings.public.track

  if Meteor.settings.public.useTrack
    # Extract raw notes from the settings.
    rawNotes = settings
        .melody
        .join ' '
        .trim()
        .split /\s+/
    noteParser = NoteParser
    bpm = settings.bpm
  else
    abcJson = parseAbcFile('greensleeves.abc')
    rawNotes = []
    for bar in abcJson.song[0][0]
      for chord in bar.chords
        for note in chord.notes
          rawNotes.push note
    bpm = abcJson.header.tempo[0]
    noteParser = new AbcNoteParser(abcJson.header.note_length)

  nextStart = 0

  # Parse the raw notes.
  notes = for rawNote in rawNotes
    note = noteParser
        .parse rawNote
        .schedule bpm, nextStart
    nextStart += note.getDuration()
    continue if note.isRest()
    note

  # If require, transpose the notes.
  if (semitones = settings.transpose)?
    notes = for note in notes
      note.transpose semitones

  # Clear out old notes and any associated utterances or words.
  Notes.remove {}
  Utterances.remove {}
  Words.remove {}

  # Create new notes.
  for note in notes
    Notes.insert
      start: note.getStart()
      duration: note.getDuration()
      frequency: note.getFrequency()


# ==============================================================================
# = Lyrics                                                                     =
# ==============================================================================

Meteor.methods
  resetLyrics: ->
    check arguments, [Match.Any]
    queueNoteInitialization()

  submitLyrics: (lyrics) ->
    check lyrics, String
    queueAssignNotesToLyrics lyrics
    return

@queueAssignNotesToLyrics = (lyrics) ->
  queue.add (done) ->
    assignNotesToLyrics lyrics
    done()

assignNotesToLyrics = (lyrics) ->
  # Assume each word is separated by whitespace.
  words = lyrics.split /\s+/

  # From each word, remove anything that isn't an apostrophe, a hyphen,
  # a period, a number, or a letter.
  words = _.map words, (word) ->
    word.replace /[^'\-.0-9a-z]/gi, ''

  # Remove empty words.
  words = _.filter words, (word) ->
    word.length > 0

  #  Saving the original case and an upper case version of the word.
  words = _.map words, (word) ->
    original: word
    upper: word.toUpperCase()

  # Try find the pronunciation of each word.
  cursor = Pronunciations.find
    _id:
      $in: _.uniq _.pluck words, 'upper'
  ,
    fields:
      syllables: 1

  syllables = {}
  cursor.forEach (pron) ->
    syllables[pron._id] = pron.syllables

  # Calculate the number of notes required: one for each syllable of
  # pronounceable words, and one for each unpronounceable word.
  iterator = (sum, word) ->
    sum + (syllables[word.upper]?.length ? 1)
  numNotes = _.reduce words, iterator, 0

  # If the number of notes is zero, return because limit: 0, is
  # actually no limit and it assign every note!
  return if numNotes == 0

  cursor = Notes.find
    assigned:
      $exists: false
  ,
    limit: numNotes
    sort: [['start', 'asc']]

  notes = cursor.fetch()

  # Mark the notes as assigned
  Notes.update
    _id:
      $in: _.pluck notes, '_id'
  ,
    $set:
      assigned: true
  ,
    multi: true

  # Identifies which utterances came from these lyrics.
  lyricsId = Random.id()

  for word, i in words

    # The notes may run out before the words do.
    break if _.isEmpty notes

    wordId = Words.insert
      createdAt: Date.now()
      index: i
      lyricsId: lyricsId
      word: word.original

    tts = (note, syllable) ->
      # Text to speech
      text = if syllable? then 'dummy' else word.original
      ssml = renderProsody text, note.frequency
      lexicon = renderLexicon text, syllable if syllable?
      wav = TTS.makeWav TTS.trimSilence TTS.makeWaveform ssml, lexicon

      Utterances.insert
        duration: note.duration
        lyricsId: lyricsId
        start: note.start
        wav: wav
        wordId: wordId

    if _.has syllables, word.upper
      for syllable in syllables[word.upper]
        # The notes may run out before the syllables do.
        note = notes.shift()
        break unless note?
        tts note, syllable
    else
      # The break at the start of the loop ensure that there is at
      # least a one note.
      tts notes.shift()

