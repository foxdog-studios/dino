Template.song.helpers
  checked: ->
    room = Rooms.findOne()
    'checked' if room? and room.currentSongId == @_id

Template.song.events
  'change [name="song"]': (e, template) ->
    element = template.find('input:radio[name="song"]:checked')
    songId = ($(element).val())
    Meteor.call 'changeSong', songId, (error, result) ->
      console.error error if error?

