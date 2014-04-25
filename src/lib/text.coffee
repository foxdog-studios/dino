@makeCleanWords = (text) ->
  dictionary = getDictionary()
  text = text.toLowerCase()
  words = text.split /\s+/
  words = _.map words, (word) ->
    (c for c in word when /[a-z]/.test c).join ''
  _.filter words, (word) ->
    dictionary.contains word

