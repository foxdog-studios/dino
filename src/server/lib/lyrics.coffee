getLyrics = _.once -> new ImplLyrics

class @Lyrics
  @clean: (lyrics) ->
    getLyrics().clean lyrics

class ImplLyrics
  _characters: (words) ->
    _.map words, (word) ->
      word.replace /[^-A-Za-z]/, ''

  _pronunciations: (words) ->
    for word in words
      pron = Pronunciations.findOne
        name: word.toUpperCase()
      ,
        fields:
          syllables: 1
      continue unless pron?
      word: word
      syllables: pron.syllables

  _split: (lyrics) ->
    lyrics.split /\s+/

  clean: (lyrics) ->
    @_pronunciations @_characters @_split lyrics

