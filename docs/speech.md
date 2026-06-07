# Speech Architecture

Speech in practice is designed as a progressive enhancement. The app should
always remain usable with the browser's built-in speech synthesis, even when
generated recordings cannot be created or loaded.

## Runtime Flow

When a practice card is assigned, the server computes the expected public audio
URL for that card. It also starts a best-effort generation step:

1. Check whether the expected object already exists in storage.
2. If it is missing, call the configured text-to-speech provider.
3. Upload the generated audio to storage.
4. Return success or an error without interrupting the practice flow.

The LiveView sends the browser both the spoken utterance and the expected audio
URL. The browser tries to preload that URL for the current card. If loading
succeeds, repeat actions use the generated recording. If loading fails or times
out, repeat actions use browser speech synthesis.

Playback failures after a successful load are not hidden by a fallback. Those
should surface as ordinary user-facing audio bugs.

## Providers

ElevenLabs is the default provider. OpenAI remains in the codebase as a simple
code-level swap for local experimentation or future fallback work.

Generated audio is stored as MP3 for broad browser compatibility. Opus may offer
better speech compression, but MP3 has fewer practical playback edge cases for
this app.

## Failure Behavior

Missing text-to-speech API keys, provider failures, missing or invalid storage
credentials, and upload failures are all TTS errors. They should be logged and
must not prevent the practice page from rendering.

Missing generated audio objects are handled by the browser preload fallback. If
the object is not available from the public URL, the browser uses speech
synthesis for that card.
