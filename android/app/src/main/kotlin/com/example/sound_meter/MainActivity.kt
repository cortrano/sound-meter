package com.example.sound_meter

import android.Manifest
import android.content.pm.PackageManager
import android.media.AudioFormat
import android.media.AudioRecord
import android.media.MediaRecorder
import android.os.Build
import androidx.core.app.ActivityCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.atomic.AtomicBoolean

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.sound_meter/audio"
    private var audioRecord: AudioRecord? = null
    private var isRecording = AtomicBoolean(false)
    private val sampleRate = 44100
    private val channelConfig = AudioFormat.CHANNEL_IN_MONO
    private val audioFormat = AudioFormat.ENCODING_PCM_16BIT
    private val bufferSize = AudioRecord.getMinBufferSize(sampleRate, channelConfig, audioFormat) * 4 // Увеличенный буфер

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "startRecording" -> {
                    if (ActivityCompat.checkSelfPermission(this, Manifest.permission.RECORD_AUDIO) != PackageManager.PERMISSION_GRANTED) {
                        result.error("PERMISSION_DENIED", "Record audio permission not granted", null)
                        return@setMethodCallHandler
                    }
                    startRecording()
                    result.success(null)
                }
                "stopRecording" -> {
                    stopRecording()
                    result.success(null)
                }
                "getSamples" -> {
                    val samples = getSamples()
                    result.success(samples)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun startRecording() {
        if (isRecording.get()) return

        try {
            audioRecord = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                AudioRecord.Builder()
                    .setAudioSource(MediaRecorder.AudioSource.MIC)
                    .setAudioFormat(
                        AudioFormat.Builder()
                            .setSampleRate(sampleRate)
                            .setChannelMask(channelConfig)
                            .setEncoding(audioFormat)
                            .build()
                    )
                    .setBufferSizeInBytes(bufferSize)
                    .build()
            } else {
                AudioRecord(MediaRecorder.AudioSource.MIC, sampleRate, channelConfig, audioFormat, bufferSize)
            }

            if (audioRecord?.state != AudioRecord.STATE_INITIALIZED) {
                throw IllegalStateException("AudioRecord not initialized")
            }

            audioRecord?.startRecording()
            isRecording.set(true)
        } catch (e: Exception) {
            println("Error starting recording: $e")
            isRecording.set(false)
            audioRecord?.release()
            audioRecord = null
        }
    }

    private fun stopRecording() {
        if (!isRecording.get()) return
        isRecording.set(false)
        try {
            audioRecord?.stop()
            audioRecord?.release()
            audioRecord = null
        } catch (e: Exception) {
            println("Error stopping recording: $e")
        }
    }

    private fun getSamples(): List<Int> {
        if (!isRecording.get() || audioRecord == null) {
            println("Not recording or audioRecord is null")
            return emptyList()
        }

        val buffer = ShortArray(bufferSize / 2) // Учитываем, что ShortArray в байтах
        var read: Int
        try {
            read = audioRecord?.read(buffer, 0, buffer.size, AudioRecord.READ_BLOCKING) ?: 0
            if (read < 0) {
                println("Error reading audio: $read")
                return emptyList()
            }
            println("Read $read samples: ${buffer.take(read).joinToString()}")
        } catch (e: Exception) {
            println("Exception in getSamples: $e")
            return emptyList()
        }
        return buffer.take(read).map { it.toInt() }
    }
}