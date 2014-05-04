# ==============================================================================
# = Character count                                                            =
# ==============================================================================

clearNumCharacters = ->
  Session.set 'numCharacters'

getNumCharacters = ->
  Session.get 'numCharacters'

updateNumCharacters = (template) ->
  numCharacters = template.find('.lyrics').value.length
  Session.set 'numCharacters', numCharacters

zeroNumCharacters = ->
  Session.set 'numCharacters', 0


# ==============================================================================
# = Submitting lyrics                                                          =
# ==============================================================================

clearSubmitting = ->
  Session.set 'submitting'

isSubmitting = ->
  Session.equals 'submitting', true

setSubmitting = ->
  Session.set 'submitting', true

submitLyrics = (template) ->
  input = template.find '.lyrics'
  setSubmitting()
  Meteor.call 'submitLyrics', input.value, (error) ->
    clearSubmitting()
    if error?
      console.warn error
    else
      input.value = ''
      Session.set 'numCharacters', 0


# ==============================================================================
# = Template                                                                   =
# ==============================================================================

Template.editor.created = ->
  clearSubmitting()
  zeroNumCharacters()

Template.editor.helpers
  isSubmitting: isSubmitting

  numCharacters: getNumCharacters

  overCount: ->
    if getNumCharacters() > 140
      'error'

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

