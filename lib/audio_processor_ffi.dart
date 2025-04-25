import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';

typedef CalculateDbNative = Double Function(Pointer<Int16>, Int32);
typedef CalculateDbDart = double Function(Pointer<Int16>, int);

final DynamicLibrary audioLib =
    Platform.isAndroid
        ? DynamicLibrary.open('libaudio_processor.so')
        : DynamicLibrary.process();

final CalculateDbDart calculateDb =
    audioLib
        .lookup<NativeFunction<CalculateDbNative>>('calculate_db')
        .asFunction();

double processAudioSamples(List<int> samples) {
  if (!Platform.isAndroid) return 0.0; // Заглушка для iOS
  final sampleCount = samples.length;
  final samplePtr = calloc<Int16>(sampleCount);

  for (var i = 0; i < sampleCount; i++) {
    samplePtr[i] = samples[i];
  }

  final db = calculateDb(samplePtr, sampleCount);
  calloc.free(samplePtr);
  return db;
}
