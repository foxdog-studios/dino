# ==============================================================================
# = Character count                                                            =
# ==============================================================================

clearNumCharacters = ->
  Session.set 'numCharacters'

getNumCharacters = ->
  Session.get 'numCharacters'

updateNumCharacters = (template) ->
  Session.set 'numCharacters', getLyrics(template).length

zeroNumCharacters = ->
  Session.set 'numCharacters', 0


# ==============================================================================
# = Lyrics                                                                     =
# ==============================================================================

getLyrics = (template) ->
  getLyricsElement(template).value

getLyricsElement = (template) ->
  template.find '[name=lyrics]'


# ==============================================================================
# = Submitting                                                                 =
# ==============================================================================

clearSubmitting = ->
  Session.set 'submitting'

isSubmitting = ->
  Session.equals 'submitting', true

setSubmitting = ->
  Session.set 'submitting', true

submitLyrics = (template) ->
  setSubmitting()
  Meteor.call 'submitLyrics', getLyrics(template), (error) ->
    clearSubmitting()
    if error?
      console.warn error
    else
      zeroNumCharacters()


# ==============================================================================
# = Template                                                                   =
# ==============================================================================

MAX_CHARACTERS = 60

Template.editor.created = ->
  clearSubmitting()
  zeroNumCharacters()

Template.editor.helpers
  isSubmitting: isSubmitting

  maxCharacters: MAX_CHARACTERS

  numCharacters: getNumCharacters

  placeholder: "Type your lyrics here. I only sing real words and I ignore
                punctuation."


Template.editor.events
  'input .lyrics': (event, template) ->
    updateNumCharacters template

  'keydown .lyrics': (event, template) ->
    if event.which == KeyCodes.ENTER
      event.preventDefault()
      submitLyrics template

  'submit': (event, template) ->
    event.preventDefault()
    submitLyrics template


Template.editor.destroyed = ->
  clearSubmitting()
  clearNumCharacters()

