Meteor.methods
  submitLyrics: (lyrics) ->
    # Validate arguments.
    check lyrics, String

    # Ensure the user is logged in.
    unless (userId = Meteor.userId())
      throw new Meteor.Error 403, 'You must be logged in'

    # If we lryics contains no valid words, stop now.
    words = LyricsProcessor.makeCleanWords lyrics
    return if _.isEmpty words

    # Identifies the lyrics this utterance comes from.
    messageId = Random.hexString 20

    # Assign a note to each word
    notes = Melody.assign words.length
    note_words = _.zip notes, words[...notes.length]

    utteranceIds = note_words.map (note_word) ->
      [note, word] = note_word

      frequency = note.getFrequency()
      ssml = """<prosody pitch="#{ frequency }Hz">#{ word }</prosody>"""
      wav = TTS.makeWav TTS.trimSilence TTS.makeWaveform ssml

      Utterances.insert
        word: word
        pitch: frequency
        offset: note.getStart()
        duration: note.getDuration()
        wav: wav
        userId: userId
        createAt: Date.now()
        messageId: messageId

    Meteor.users.update userId,
      $set:
        'profile.utteranceIds': utteranceIds

    return

