# ==============================================================================
# = Progress                                                                   =
# ==============================================================================

ID = 'progress'

Meteor.publish ID, ->
  @added ID, ID, progress: 0
  update = =>
    @changed ID, ID,
      progress: 100 * (Utterances.find().count() / Notes.find().count())
  handle = Utterances.find().observeChanges
    added: update
    removed: update
  @onStop -> handle.stop()
  @ready()


# ==============================================================================
# = Rooms                                                                      =
# ==============================================================================

Meteor.publish 'rooms', ->
  Rooms.find(name: 'default')


# ==============================================================================
# = Songs                                                                      =
# ==============================================================================

Meteor.publish 'songs', ->
  Songs.find {},
    sort: [['fileName', 'asc']]


# ==============================================================================
# = Utterances                                                                 =
# ==============================================================================

Meteor.publish 'utterances', ->
  Utterances.find {},
    sort: [['createdAt', 'asc']]


# ==============================================================================
# = Words                                                                      =
# ==============================================================================

Meteor.publish 'words', ->
  Words.find {},
    sort: [['createdAt', 'asc']]
    fields:
      createdAt: 0

