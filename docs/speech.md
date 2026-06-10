# Speech Architecture

Speech in practice is designed as a progressive enhancement. The app should
always remain usable with the browser's built-in speech synthesis, even when
generated recordings cannot be created or loaded.

## Runtime Flow

When a practice card is assigned, the server computes the expected public audio
URL for that card. It does not check storage, call a text-to-speech provider, or
upload audio during the practice flow.

The LiveView sends the browser both the spoken utterance and the expected audio
URL. The browser tries to preload that URL for the current card. If loading
succeeds, repeat actions use the generated recording. If loading fails or times
out, repeat actions use browser speech synthesis.

Playback failures after a successful load are not hidden by a fallback. Those
should surface as ordinary user-facing audio bugs.

## Providers

Generated audio is created explicitly from IEx with `Red.Audio.Generator`.
ElevenLabs is the configured provider.

Generated audio is stored as MP3 for broad browser compatibility. Opus may offer
better speech compression, but MP3 has fewer practical playback edge cases for
this app.

## Generating Audio

From IEx:

```elixir
Red.Audio.Generator.generate("have")
Red.Audio.Generator.generate_all()
```

`generate/1` looks up the word in the loaded word lists. `generate_all/0` walks
every loaded word-list entry.

## Failure Behavior

Missing text-to-speech API keys, provider failures, missing or invalid writable
storage credentials, and upload failures are generation errors. They happen only
when running `Red.Audio.Generator`, not while serving the practice page.

Missing generated audio objects are handled by the browser preload fallback. If
the object is not available from the public URL, the browser uses speech
synthesis for that card.
