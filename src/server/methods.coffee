Meteor.methods
  'sendText': (text) ->
    return unless Meteor.user()
    console.log text

  'tts': (ssml) ->
    buffer = TTS.makeWav TTS.trimSilence TTS.tts ssml
    array = new ArrayBuffer buffer.length
    view = new Uint8Array array
    for i in [0...buffer.length]
     view[i] = buffer.readUInt8 i
    view

