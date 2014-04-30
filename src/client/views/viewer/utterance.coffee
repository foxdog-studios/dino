Template.utterance.helpers
  class: ->
    nextBeat = Metronome.getNextBeat()

    cursor = Utterances.find
      _id: @_id
      playbackStart:
        $lte: nextBeat.time
      playbackEnd:
        $gt: nextBeat.time
    ,
      sort:
        playbackStart: 1

    if cursor.count()
      'current-utterance'

