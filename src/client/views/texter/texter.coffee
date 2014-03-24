PASSWORD = 'dummy password for everyone'

validateText = (text) ->
  if text == ''
    return false
  true

Template.texter.created = ->
  Deps.autorun ->
    return if Meteor.loggingIn() or Meteor.user()
    Accounts.createUser
      username: Random.hexString(32)
      password: PASSWORD
      profile:
        userAgent: navigator.userAgent
        name: generateName()
    , (error) ->
      if error?
        # XXX: Just log the error
        console.log "Error creating user #{error}"

Template.texter.events
  'click #send': (e) ->
    $textArea = $('#text')
    text = $textArea.val()
    if validateText(text)
      $textArea.prop('disabled', true)
      Meteor.call 'sendText', text, (error, result) ->
        $textArea.prop('disabled', false)
        if error?
          console.log error
        else
          $textArea.val('')

