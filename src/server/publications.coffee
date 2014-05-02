# ==============================================================================
# = Progress                                                                   =
# ==============================================================================

PROGRESS_ID = 'progress'

Meteor.publish 'progress', ->
  initializing = true

  count = 0
  getProgress = ->
    count / Melody.numNotes() * 100

  handle = Utterances.find().observeChanges
    added: (id, fields) =>
      count++
      return if initializing
      @changed 'progress', PROGRESS_ID, progress: getProgress()

    removed: (id) =>
      count--
      @changed 'progress', PROGRESS_ID, progress: getProgress()
  @onStop ->
    handle.stop()

  initializing = false
  @added 'progress', PROGRESS_ID, progress: getProgress()
  @ready()


# ==============================================================================
# = Utterances                                                                 =
# ==============================================================================

Meteor.publish 'utterances', ->
  Utterances.find {},
    order: [['createdAt', 'asc']]


