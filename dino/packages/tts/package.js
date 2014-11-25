'use strict';

Package.describe({
  summary: 'Text-to-speech',
  name: 'tts',
  version: '0.0.0'
});

Package.onUse(function (api) {
  api.addFiles('tts.js', 'server');
  api.export('TTS', 'server');
});

Npm.depends({
  'tts-swift': 'https://github.com/foxdog-studios/node-tts/tarball/e166d8ce6ecc59e948bb4cd698e69f6b8b7bab0f'
});

