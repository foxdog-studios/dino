class KeyCodes
  @Return = 13

Template.editorLoggedIn.rendered = ->
  if (lyrics = getUserLyrics())
    Session.set 'characterCount', lyrics.length
  else
    Session.set 'characterCount', 0

Template.editorLoggedIn.helpers
  characterCount: ->
    Session.get 'characterCount'

  preview: ->
    makePreviewWords()?.join ' '

  initialLyrics: ->
    Deps.nonreactive getUserLyrics

  lyricsDisabled: ->
    Session.equals 'submitting', true

  submitting: ->
    Session.equals 'submitting', true

  sumbitDisabled: ->
    if Session.equals('submitting', true)
      true
    else
      words = makePreviewWords()
      not words or words.length == 0

  overCount: ->
    'error' if Session.get('characterCount') > 140

Template.editorLoggedIn.events
  'input #lyrics': (event, template) ->
    lyrics = getInputLyrics(template)
    Session.set('characterCount', lyrics.length)
    Meteor.users.update Meteor.userId(),
      $set:
        'profile.lyrics': lyrics

  'keypress #lyrics': (event) ->
    if event.which == KeyCodes.Return
      event.preventDefault()
      $('#lyrics').submit()

  'submit': (event, template) ->
    event.preventDefault()
    lyrics = getInputLyrics template
    Session.set 'submitting', true
    Methods.submitLyrics lyrics, (error, result) ->
      Session.set 'submitting', false
      if error?
        console.warn error
        return
      template.find('#lyrics').value = ''
      Session.set('characterCount', 0)
      Meteor.users.update Meteor.userId(),
        $unset:
          'profile.lyrics': ''

getInputLyrics = (template) ->
  template.find('#lyrics').value

getUserLyrics = ->
  Meteor.user()?.profile?.lyrics

makePreviewWords = ->
  if (lyrics = getUserLyrics())
    LyricsProcessor.makeCleanWords lyrics

setSelectionRange = (input, selectionStart, selectionEnd) ->
  if input.setSelectionRange
    input.focus()
    input.setSelectionRange selectionStart, selectionEnd
  else if input.createTextRange
    range = input.createTextRange()
    range.collapse true
    range.moveEnd 'character', selectionEnd
    range.moveStart 'character', selectionStart
    range.select()

