Meteor.methods
  submitLyrics: (lyrics) ->
    # Validate arguments.
    check lyrics, String

    # Ensure the user is logged in.
    unless (userId = Meteor.userId())
      throw new Meteor.Error 403, 'You must be logged in'

    # Validate the lyrics.
    words = makeCleanWords lyrics
    if _.isEmpty words
      throw new Meteor.Error 422, 'No valid lyrics supplied', lyrics

    # Assign a note to each word
    cursor = Notes.find
      ownerId:
        $exists: false
    ,
      sort: [['offset', 'asc']]
      limit: words.length

    note_words = _.zip(cursor.fetch(), words[...cursor.count()])

    utteranceIds = note_words.map (note_word) ->
      [note, word] = note_word

      # Assign the note to the user.
      Notes.update note._id,
        $set:
          ownerId: userId

      utterance =
        word: word
        pitch: note.pitch
        offset: note.offset
        duration: note.duration
        userId: userId
        createAt: Date.now()

      if Meteor.isServer
        ssml = """<prosody pitch="#{ note.pitch }Hz">#{ word }</prosody>"""
        utterance.wav = TTS.makeWav TTS.trimSilence TTS.makeWaveform ssml

      Utterances.insert utterance

    Meteor.users.update userId,
      $set:
        'profile.utteranceIds': utteranceIds

    return

