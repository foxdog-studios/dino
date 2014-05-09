createSequencer = ->
  new Sequencer getAudioContext()

getSequencer = _.once -> createSequencer()

createMetronome = (ticksPerBeat) ->
  beatsPerMinute = Meteor.settings.public.track.bpm
  getSequencer().createMetronome(beatsPerMinute, ticksPerBeat)

getBeatMetronome = _.once -> createMetronome 1
getHalfBeatMetronome = _.once -> createMetronome 2

class @DinoMetronome
  @getTimeAtNextBeat: ->
    getBeatMetronome().getTimeAtNextTick()

  @getTimeAtNextHalfBeat: ->
    getHalfBeatMetronome().getTimeAtNextTick()

