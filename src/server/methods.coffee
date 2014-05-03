Meteor.methods
  submitLyrics: (lyrics) ->
    # Validate arguments.
    check lyrics, String

    # Ensure the user is logged in.
    unless (userId = Meteor.userId())
      throw new Meteor.Error 403, 'You must be logged in'

    # Pronunciations for each word in the cleaned lyrics.
    prons = Lyrics.clean lyrics
    return if _.isEmpty prons

    # Identifies the lyrics this utterance comes from.
    messageId = Random.hexString 20

    # The number of syllables in the message, which is also the number
    # of notes we need.
    iterator = (sum, pron) -> sum + pron.syllables.length
    numSyllables = _.reduce prons, iterator, 0

    # Assign a note to each syllable
    notes = getMelody().assignAtMost numSyllables

    for pron in prons
      for syllable in pron.syllables
        note = notes.shift()
        break unless note?
        ssml = renderSsml syllable, note.getFrequency()
        pcm = TTS.makeWaveform ssml.ssml, ssml.lexicon
        wav = TTS.makeWav TTS.trimSilence pcm
        Utterances.insert
          word: pron.word
          pitch: note.getFrequency()
          offset: note.getStart()
          duration: note.getDuration()
          wav: wav
          messageId: messageId
      break if _.isEmpty notes

    return # nothing

