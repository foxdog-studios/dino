window.AudioContext = window.AudioContext || window.webkitAudioContext

unless AudioContext
  Session.set 'error', 'Web audio not supported'

