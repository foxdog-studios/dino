crypto = Npm.require 'crypto'

class TwilioMessageSyncer
  _digestPassword: (password) ->
    crypto
      .createHash('sha256')
      .update(password)
      .digest 'hex'

  syncMessages: ->
    twilio = DDP.connect Meteor.settings.twilio.url
    digestPassword = @_digestPassword(
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

    @messages = new Meteor.Collection 'messages',
      connection: twilio

  _observeMessages: (lastChanged) ->
    if @_messageHandle?
      @_messageHandle.stop()
    cursor = @messages.find
      dateCreated:
        $gte: lastChanged
    @_messageHandle = cursor.observe
      added: (message) ->
        queueAssignNotesToLyrics(message.body)

  observeMessages: ->
    unless @messages?
      throw 'Incorrect state, call syncMessages() first'
    if @_roomHandle?
      @_roomHandle.stop()
    roomCursor = Rooms.find(name: 'default')
    @_roomHandle = roomCursor.observeChanges
      added: (id, fields) =>
        return unless fields.lastChanged?
        @_observeMessages(fields.lastChanged)
      changed: (id, fields) =>
        return unless fields.lastChanged?
        @_observeMessages(fields.lastChanged)


Meteor.startup ->
  return unless Meteor.settings.twilio.enabled
  messageSyncer = new TwilioMessageSyncer()
  messageSyncer.syncMessages()
  messageSyncer.observeMessages()

