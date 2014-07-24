crypto = Npm.require 'crypto'

class TwilioMessageSyncer
  @digestPassword: (password) ->
    crypto
      .createHash('sha256')
      .update(password)
      .digest 'hex'

  @syncMessages: ->
    twilio = DDP.connect Meteor.settings.twilio.url
    digestPassword = TwilioMessageSyncer.digestPassword(
      Meteor.settings.twilio.password
    )
    twilio.call 'login',
      password:
        digest: digestPassword
        algorithm: "sha-256"
      user:
        username: Meteor.settings.twilio.username
    ,
      (error, result) ->
        console.log error if error?
        twilio.subscribe 'inbound',
          onError: (error) ->
            console.log error

    Messages = new Meteor.Collection 'messages',
      connection: twilio

    Messages.find().observe
      added: (message) ->
        queueAssignNotesToLyrics(message.body)

if Meteor.settings.twilio.enabled
  TwilioMessageSyncer.syncMessages()

