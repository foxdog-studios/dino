Package.describe({
    summary: "Text-to-speech"
});

Npm.depends({
  tts: 'https://github.com/foxdog-studios/node-tts/tarball/2ffa08fd3f36df54e6a05ab417a2c5a510db5fb4'
});

Package.on_use(function (api) {
  api.add_files(['tts.js'], 'server');
  api.export(['TTS'], 'server');
});

