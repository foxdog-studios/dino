Template.editorLoggedIn.helpers
  preview: ->
    makePreviewWords()?.join ' '

  initialLyrics: ->
    Deps.nonreactive getUserLyrics

  sumbitDisabled: ->
    words = makePreviewWords()
    Session.equals('submitting', true) or not words? or words.length == 0

Template.editorLoggedIn.events
  'input #lyrics': (event, template) ->
    Meteor.users.update Meteor.userId(),
      $set:
        'profile.lyrics': getInputLyrics template

  'submit': (event, template) ->
    event.preventDefault()
    lyrics = getInputLyrics template
    Session.set 'submitting', true
    Methods.submitLyrics lyrics, (error, result) ->
      Session.set 'submitting', false
      return if error?
      template.find('#lyrics').value = ''
      Meteor.users.update Meteor.userId(),
        $unset:
          'profile.lyrics': ''

getInputLyrics = (template) ->
  template.find('#lyrics').value

getUserLyrics = ->
  Meteor.user()?.profile?.lyrics

makePreviewWords = ->
  if (lyrics = getUserLyrics())
    makeCleanWords lyrics
