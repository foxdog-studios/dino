class ProfanityFilterRegex
  constructor: (@_word, @_replacement) ->

  build: ->
    characters = @_word.split('')
    pattern = "#{characters.join('+')}+"
    @_regExp = new RegExp(pattern, 'gi')

  replace: (string) ->
    unless @_regExp?
      throw 'Illegal State, call build() first'
    string.replace(@_regExp, @_replacement)


class @ProfanityFilter
  class ProfanityFilterImpl
    constructor: (@_dictionary) ->
      @_profanityFilterRegexes = []

    build: ->
      for profanity, replacement of @_dictionary
        profanityFilterRegex = new ProfanityFilterRegex(profanity, replacement)
        profanityFilterRegex.build()
        @_profanityFilterRegexes.push(profanityFilterRegex)

    clean: (word) ->
      for profanityFilterRegex in @_profanityFilterRegexes
        word = profanityFilterRegex.replace(word)
      word

  instance = null

  fromSettings = ->
    filter = new ProfanityFilterImpl(Meteor.settings.profanityFilterDictionary)
    filter.build()
    filter

  @getInstance = ->
    instance ?= fromSettings()

