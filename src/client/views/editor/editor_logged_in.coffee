Template.editorLoggedIn.rendered = ->
  if (lyrics = getUserLyrics())
    setCaretToPos @find('#lyrics'), lyrics.length

Template.editorLoggedIn.helpers
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
    LyricsProcessor.makeCleanWords lyrics

setCaretToPos = (input, pos) ->
  setSelectionRange input, pos, pos

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

