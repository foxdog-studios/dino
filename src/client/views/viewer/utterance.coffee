Template.utterance.helpers
  class: ->
    nextBeat = Metronome.getNextBeat()

    cursor = Utterances.find
      _id: @_id
      playbackStart:
        $lte: nextBeat
      playbackEnd:
        $gt: nextBeat
    ,
      sort:
        playbackStart: 1

    if cursor.count() > 0
      'current-utterance'

