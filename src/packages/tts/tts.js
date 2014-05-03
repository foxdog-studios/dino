TTS = (function () {
  var fs = Npm.require('fs');

  var _tts = new Npm.require('tts').Tts();

  var tts = {}

  tts.makeWaveform = function (ssml, lexicon) {
    if (lexicon) {
      // TODO: Use secure temporary file with clean up.
      var lexiconPath = '/tmp/lexicon.txt';
      fs.writeFileSync(lexiconPath, lexicon);
      _tts.tryLoadLexicon(lexiconPath);
      fs.unlinkSync(lexiconPath);
    }
    return _tts.createWaveform(ssml);
  };

  tts.makeWav = function (bytes) {
    var bitsPerSample = 16;
    var bytesPerSample = bitsPerSample / 8;
    var sampleRate = 16000;

    //
    // Compute WAVE field values
    //

    var chunkId = 'RIFF';

    // Header

    // Does not include ChunkID (4) or ChunkSize (4), just Format (4).
    var headerSize = 4;
    var subchunk1HeaderSize = 8;
    var subchunk1Size = 16;

    // Calculate the size of subchunk 2
    var subchunk2HeaderSize = 8;
    var numSamples          = bytes.length / 2;
    var numChannels         = 1;
    var numBlocks           = numSamples / numChannels;
    var subchunk2Size       = numBlocks * numChannels * bytesPerSample;

    // Calculate the size of the entire chunk
    var chunkSize = (
        headerSize
        + subchunk1HeaderSize
        + subchunk1Size
        + subchunk2HeaderSize
        + subchunk2Size
    );

    // Calculate the size fo the entire wave file
    var chunkSizeSize = 4; // bytes
    var fileSize = chunkId.length + chunkSizeSize + chunkSize; // bytes

    var format = 'WAVE';

    // Subchunk 1

    var subchunk1Id = 'fmt '; // The space after fmt is required padding
    var audioFormat = 1;      // PCM
    var byteRate    = sampleRate * numChannels * bytesPerSample;
    var blockAlign  = numChannels * bytesPerSample;

    // Subchunk 2

    var subchunk2Id = 'data';

    //
    // Write WAVE file
    //

    var out = new Buffer(fileSize);
    var end = 0;

    var write = function (string) {
      out.write(string, end, string.length);
      end += string.length;
    };
    var writeInt = function (value) {
      out.writeUInt32LE(value, end);
      end += 4;
    };

    var writeShort = function(value) {
      out.writeUInt16LE(value, end);
      end += 2;
    }

    // RIFF chunk descriptor
    write(chunkId);            // ChunkID
    writeInt(chunkSize);       // ChunkSize (B)
    write(format);             // Format

    // fmt sub-chunk
    write(subchunk1Id);        // Subchunk1ID
    writeInt(subchunk1Size);   // Subchunk1Size (B)
    writeShort(audioFormat);   // AudioFormat
    writeShort(numChannels);   // NumChannels
    writeInt(sampleRate);      // Samplerate (Hz)
    writeInt(byteRate);        // ByteRate (B s^-1)
    writeShort(blockAlign);    // BlockAlign (B smaples^-1)
    writeShort(bitsPerSample); // BitsPerSample (b samples^-1)

    // data sub-chunk
    write(subchunk2Id);        // Subchunk2ID
    writeInt(subchunk2Size);   // Subchunk2Size (B)
    bytes.copy(out, end);

    return out;
  };

  tts.trimSilence = function (bytes) {
    var numBytes = bytes.length;
    for (var i = 0; i < numBytes; i += 2) {
      if (bytes.readInt16LE(i) > 0) {
        break;
      }
    }
    var start = i;
    for (i = numBytes - 2; i >= 0; i -= 2) {
      if (bytes.readInt16LE(i) > 0) {
        break;
      }
    }
    var end = i + 1;
    return bytes.slice(start, end);
  };

  return tts
}());

