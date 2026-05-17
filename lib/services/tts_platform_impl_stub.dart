/// Stub — provides the factory API used by [tts_provider.dart].
/// The real implementations live in [tts_io.dart] (native) and
/// [tts_web.dart] (web).  This file must never be imported directly.
library;

import 'tts_service.dart';

TtsAudioCache makeTtsCache() => throw UnsupportedError('stub');
TtsAudioPlayer makeTtsPlayer() => throw UnsupportedError('stub');
