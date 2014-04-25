Template.editorLoggedIn.helpers
  preview: ->
    makePreviewWords()?.join ' '

  lyricsInvalid: ->
    words = makePreviewWords()
    not words? or words.length == 0

  initialLyrics: ->
    Deps.nonreactive getUserLyrics

Template.editorLoggedIn.events
  'input #lyrics': (event, template) ->
    Meteor.users.update Meteor.userId(),
      $set:
        'profile.lyrics': getInputLyrics template

  'submit': (event, template) ->
    event.preventDefault()
    lyrics = getInputLyrics template
    Methods.submitLyrics lyrics, (error, words) ->
      console.log error, words

getInputLyrics = (template) ->
  template.find('#lyrics').value

getUserLyrics = ->
  Meteor.user()?.profile?.lyrics

makePreviewWords = ->
  if (lyrics = getUserLyrics())
    makeCleanWords lyrics
