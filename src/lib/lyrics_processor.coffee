class ImplLyricsProcessor
  constructor: ->
    settings = _.defaults Meteor.settings?.public?.lyrics || {},
      alpha: true
      dictionary: true
      lower: true

    @_processors = []

    push = (processor, condition = true) =>
      @_processors.push _.bind processor, this if condition

    push @_lower, settings.lower
    push @_split
    push @_alpha, settings.alpha
    push @_nonEmpty, settings.nonEmpty
    push @_pronounceable, settings.pronounceable

  _alpha: (words) ->
    _.map words, (word) ->
      (c for c in word when /[a-z]/.test c).join ''

  _pronounceable: (words) ->
    if Meteor.isServer
      _.filter words, (word) ->
        cursor = Pronunciations.find
          name: word.toUpperCase()
        ,
          limit: 1
        cursor.count() != 0
    else
      words

  _lower: (lyrics) ->
    lyrics.toLowerCase()

  _nonEmpty: (words) ->
    _.filter words, (word) ->
      word.length > 0

  _split: (lyrics) ->
    lyrics.split /\s+/

  makeCleanWords: (lyrics) ->
    result = lyrics
    for processor in @_processors
      result = processor result
    result

lyricsProcessor = null

getLyricsProcessor = ->
  lyricsProcessor = new ImplLyricsProcessor unless lyricsProcessor
  lyricsProcessor

class @LyricsProcessor
  @makeCleanWords: (lyrics) ->
    getLyricsProcessor().makeCleanWords lyrics

