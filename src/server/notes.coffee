class ImplNotes
  constructor: ->
    @_isLocked = false
    @_remaining = []

  _aquire: ->
    if @_isLocked
      throw 'Cannot aquire lock, it is already aquired.'
    @_isLocked = true

  _release: ->
    unless @_isLocked
      throw 'Cannot release lock, it has already been released.'
    @_isLocked = false

  _withLock: (func) ->
    @_aquire()
    result = func()
    @_release()
    result

  _checkNotes: (notes) ->
    check notes, [
      pitch: Number
      offset: Number
      duration: Number
    ]

  _checkMaxNotes: (maxNotes) ->
    check maxNotes, Number

  _cloneNotes: (notes) ->
    _.clone notes

  reset: (notes) ->
    @_checkNotes notes
    @_withLock =>
      @_remaining = @_cloneNotes notes

  assign: (maxNotes) ->
    @_checkMaxNotes maxNotes
    @_withLock =>
      @_remaining.splice 0, maxNotes

  numRemaining: ->
    @_withLock =>
      @_remaining.length

notes = null

getNotes = ->
  notes ||= new ImplNotes

class @Notes
  @reset: (notes) ->
    getNotes().reset notes

  @assign: (maxNotes) ->
    getNotes().assign maxNotes

  @numRemaining: ->
    getNotes().numRemaining()

