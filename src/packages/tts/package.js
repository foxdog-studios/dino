Package.describe({
    summary: "Text-to-speech"
});

Npm.depends({
  tts: 'https://github.com/foxdog-studios/node-tts/tarball/6629c23836f4827b537cb0386134cd3b08b65216'
});

Package.on_use(function (api) {
  api.add_files(['tts.js'], 'server');
  api.export(['TTS'], 'server');
});

