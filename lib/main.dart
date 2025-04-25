import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';
import 'audio_processor_ffi.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sound Meter',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const SoundMeterScreen(),
    );
  }
}

class SoundMeterScreen extends StatefulWidget {
  const SoundMeterScreen({super.key});

  @override
  _SoundMeterScreenState createState() => _SoundMeterScreenState();
}

class _SoundMeterScreenState extends State<SoundMeterScreen> {
  static const platform = MethodChannel('com.example.sound_meter/audio');
  bool _isRecording = false;
  double _decibels = 0.0;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    if (await Permission.microphone.request().isGranted) {
      print("Microphone permission granted");
    } else {
      print("Microphone permission denied");
    }
  }

  Future<void> _startRecording() async {
    try {
      await platform.invokeMethod('startRecording');
      setState(() {
        _isRecording = true;
      });
      _updateDecibels();
    } catch (e) {
      print('Error starting recording: $e');
      setState(() {
        _isRecording = false;
      });
    }
  }

  Future<void> _stopRecording() async {
    try {
      await platform.invokeMethod('stopRecording');
      setState(() {
        _isRecording = false;
        _decibels = 0.0;
      });
    } catch (e) {
      print('Error stopping recording: $e');
    }
  }

  Future<void> _updateDecibels() async {
    while (_isRecording) {
      try {
        final samples = await platform.invokeMethod<List<dynamic>>(
          'getSamples',
        );
        if (samples != null && samples.isNotEmpty) {
          final db = processAudioSamples(samples.cast<int>());
          setState(() {
            _decibels = db;
          });
          print("Decibels: $db");
        } else {
          print("No samples received");
        }
        await Future.delayed(const Duration(milliseconds: 200));
      } catch (e) {
        print('Error getting samples: $e');
        setState(() {
          _isRecording = false;
        });
        await _stopRecording();
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sound Meter')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Decibels: ${_decibels.toStringAsFixed(1)} dB',
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isRecording ? _stopRecording : _startRecording,
              child: Text(_isRecording ? 'Stop Recording' : 'Start Recording'),
            ),
          ],
        ),
      ),
    );
  }
}
