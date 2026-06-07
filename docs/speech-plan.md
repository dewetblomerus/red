# Speech Implementation Plan

This file captures implementation details for the speech branch. It can be
removed after the feature ships.

## Tasks

- Add `Red.Audio.ElevenLabs` as the default TTS provider.
- Keep `Red.Audio.OpenAI` available as a code-level provider swap.
- Add storage helpers that wrap S3 checks and uploads in tagged results.
- Update `Red.Audio.Transcriber` so external failures return errors instead of
  raising.
- Update `PracticeLive` to ignore/log TTS errors and still assign cards.
- Update the `Say` browser hook to preload the generated audio URL once per
  card and choose generated audio or browser speech based on load success.
- Remove visible multi-voice audio controls from the practice form.

## Acceptance Criteria

- The practice page works when the ElevenLabs API key is missing.
- The practice page works when S3 credentials are missing or invalid.
- If a generated audio object cannot be loaded by the browser, repeat actions
  use browser speech synthesis.
- If generated audio loads successfully, repeat actions use that recording.
- If playback fails after successful load, the failure is allowed to surface.

## Test Scenarios

- Missing ElevenLabs key returns `{:error, :missing_api_key}`.
- Existing storage object skips provider generation.
- Missing storage object with successful provider uploads generated audio.
- Storage credential failure returns an error and does not crash.
- Provider failure returns an error and does not crash.
- `PracticeLive.assign_card/1` still assigns a card when transcription fails.
- The `Say` event includes both `utterance` and `audio_url`.
