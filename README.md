# Sound Meter

Простое Flutter-приложение для измерения громкости звука в децибелах с помощью микрофона устройства. Работает на Android и iOS.
Использует платформенные каналы для обращения к микрофону, C-код для расчёта громкости.

## Структура проекта

`lib/` — Dart-код приложения:

`main.dart` — основной UI и логика.

- `audio_processor_ffi.dart` — FFI для нативной библиотеки.

`android/` — нативный код для Android:

`app/src/main/kotlin/.../MainActivity.kt` — работа с `AudioRecord`.

- `app/src/main/jniLibs/` — `libaudio_processor.so`.

`ios/` — нативный код для iOS:

`Runner/` — работа с аудиозаписью.

`native/` — исходники C-библиотеки для обработки аудио.
