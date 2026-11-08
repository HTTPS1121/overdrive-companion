/// Matches upstream `RemoteCommunicationPolicy` + `communicate.js`.
abstract final class CommunicateProtocol {
  static const pcmSampleRateHz = 16000;
  static const pcmFormat = 'pcm_s16le';
  static const maxSessionMs = 30_000;
  static const audioInactivityMs = 4_000;
  static const maxPcmFrameBytes = 32 * 1024;

  static const pathCommunicate = '/ws/communicate';
  static const pathCabinAudio = '/ws/cabin-audio';
}

abstract final class CommunicateJsonType {
  static const connected = 'connected';
  static const live = 'live';
  static const failed = 'failed';
  static const stopped = 'stopped';
  static const start = 'start';
  static const stop = 'stop';
}

abstract final class CabinAudioJsonType {
  static const starting = 'starting';
  static const ready = 'ready';
  static const paused = 'paused';
  static const resumed = 'resumed';
  static const failed = 'failed';
  static const stopped = 'stopped';
}

abstract final class GenAiVoiceProtocol {
  static const path = '/ws/genai';
  static const maxClientBufferedBytes = 262144;
}

abstract final class GenAiVoiceJsonType {
  static const connected = 'connected';
  static const live = 'live';
  static const state = 'state';
  static const failed = 'failed';
  static const stopped = 'stopped';
  static const stop = 'stop';
  static const truncate = 'truncate';
  static const audioItem = 'audio_item';
  static const clear = 'clear';
  static const transcriptDelta = 'transcript_delta';
  static const transcriptDone = 'transcript_done';
}
