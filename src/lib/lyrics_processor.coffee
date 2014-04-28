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
    push @_dictionary, settings.dictionary

  _alpha: (words) ->
    _.map words, (word) ->
      (c for c in word when /[a-z]/.test c).join ''

  _dictionary: (words) ->
    dictionary = getDictionary()
    _.filter words, (word) ->
      dictionary.contains word

  _lower: (lyrics) ->
    lyrics.toLowerCase()

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

