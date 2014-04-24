PASSWORD = 'dummy password for everyone'

validateText = (text) -> text != ''

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

window.AudioContext = window.AudioContext || window.webkitAudioContext;
context = new AudioContext

Template.texter.events
  'click #send': (event) ->
    event.preventDefault()
    Meteor.call 'tts', $('#text').val(), (error, wav) ->
      return if error?

      successCallback = (buffer) ->
        source = context.createBufferSource()
        source.buffer = buffer
        source.connect context.destination
        source.start 0

      errorCallback = ->
        console.log 'An error occured while decoding audio data.'

      context.decodeAudioData wav.buffer, successCallback, errorCallback

