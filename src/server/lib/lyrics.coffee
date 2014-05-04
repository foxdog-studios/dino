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

  # Extract raw notes from the settings.
  rawNotes = settings
      .melody
      .join ' '
      .trim()
      .split /\s+/

  bpm = settings.bpm

  nextStart = 0

  # Parse the raw notes.
  notes = for rawNote in rawNotes
    note = NoteParser
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

queueAssignNotesToLyrics = (lyrics) ->
  queue.add (done) ->
    assignNotesToLyrics lyrics
    done()

assignNotesToLyrics = (lyrics) ->
  # Assume each word is separated by whitespace.
  words = lyrics.split /\s+/

  # From each word:
  #   * Remove anything that isn't a;
  #     * Letter
  #     * Apostrophe
  #     * Hyphne letter
  #
  #   * Convert into an object saving original case and upper case
  #     versions of the word.

  words = _.map words, (word) ->
    word = word.replace /[^a-z'-]/i, ''
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

  # Remove words that cannot be pronounced.
  words = _.filter words, (word) ->
    _.has syllables, word.upper

  # Calculate the number of notes required: one for each syllable of
  # the cleaned lyrics.
  iterator = (sum, word) ->
    sum + syllables[word.upper].length
  numNotes = _.reduce words, iterator, 0

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

    for syllable in syllables[word.upper]

      # The notes may run out before the syllables do.
      note = notes.shift()
      break unless note?

      # Text-to-speech
      ssml = renderSsml syllable, note.frequency
      pcm = TTS.makeWaveform ssml.ssml, ssml.lexicon
      wav = TTS.makeWav TTS.trimSilence pcm

      Utterances.insert
        duration: note.duration
        lyricsId: lyricsId
        start: note.start
        wav: wav
        wordId: wordId

