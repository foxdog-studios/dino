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
# = Utterances                                                                 =
# ==============================================================================

Meteor.publish 'utterances', ->
  Utterances.find {},
    order: [['createdAt', 'asc']]


# ==============================================================================
# = Words                                                                      =
# ==============================================================================

Meteor.publish 'words', ->
  Words.find {},
    order: [['createdAt', 'asc']]
    fields:
      createdAt: 0

