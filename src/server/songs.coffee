fs = Npm.require('fs')
path = Npm.require('path')
meteor_root = fs.realpathSync( process.cwd() + '/../' )
assets_root = "#{meteor_root}/server/assets/app/"


Meteor.startup ->
  Songs.remove {}
  files = fs.readdirSync(assets_root)
  for file in files
    continue unless path.extname(file) == '.abc'
    id = Songs.insert fileName: file
    if file == Meteor.settings.defaultAbcFile
      room = Rooms.upsert
        name: 'default'
      ,
        name: 'default'
        currentSongId: id

Meteor.methods
  changeSong: (songId) ->
    check songId, String
    Rooms.upsert
      name: 'default'
    ,
      name: 'default'
      currentSongId: songId
    queueNoteInitialization()

