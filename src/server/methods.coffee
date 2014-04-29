Meteor.methods
  submitLyrics: (lyrics) ->
    # Validate arguments.
    check lyrics, String

    # Ensure the user is logged in.
    unless (userId = Meteor.userId())
      throw new Meteor.Error 403, 'You must be logged in'

    # Validate the lyrics.
    words = LyricsProcessor.makeCleanWords lyrics
    if _.isEmpty words
      throw new Meteor.Error 422, 'No valid lyrics supplied', lyrics

    # Identifies the lyrics this utterance comes from.
    messageId = Random.hexString 20

    # Assign a note to each word
    notes = Notes.assign words.length
    note_words = _.zip notes, words[...notes.length]

    utteranceIds = note_words.map (note_word) ->
      [note, word] = note_word

      ssml = """<prosody pitch="#{ note.pitch }Hz">#{ word }</prosody>"""
      wav = TTS.makeWav TTS.trimSilence TTS.makeWaveform ssml

      Utterances.insert
        word: word
        pitch: note.pitch
        offset: note.offset
        duration: note.duration
        wav: wav
        userId: userId
        createAt: Date.now()
        messageId: messageId

    Meteor.users.update userId,
      $set:
        'profile.utteranceIds': utteranceIds

    return

