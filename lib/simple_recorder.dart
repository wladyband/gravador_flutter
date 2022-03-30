
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_sound_platform_interface/flutter_sound_recorder_platform_interface.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/timer_controller.dart';

class SimpleRecorder extends StatefulWidget {
  const SimpleRecorder({Key? key}) : super(key: key);

  @override
  _SimpleRecorderState createState() => _SimpleRecorderState();
}

class _SimpleRecorderState extends State<SimpleRecorder> {
  final FlutterSoundRecorder _mRecorder = FlutterSoundRecorder();
  final FlutterSoundPlayer _mPlayer = FlutterSoundPlayer();

  final _timerController = TimerController();

  bool _mPlayerIsInited = false;
  bool _mRecorderIsInited = false;
  bool _mplaybackReady = false;

  @override
  void initState() {
    Permission.microphone.request().then((status) {
      if (status != PermissionStatus.granted) {
        throw RecordingPermissionException('Microphone permission not granted');
      }

      _mRecorder.openRecorder().then((value) {
        setState(() {
          _mRecorderIsInited = true;
        });
      });

      _mPlayer.openPlayer().then((value) {
        setState(() {
          _mPlayerIsInited = true;
        });
      });
    });

    super.initState();
  }

  @override
  void dispose() {
    _mRecorder.closeRecorder();
    _mPlayer.closePlayer();
    _timerController.reset();

    super.dispose();
  }

  void onRecordPressed() {
    if (!_mRecorderIsInited || !_mPlayer.isStopped) {
      return;
    }

    _mRecorder.isStopped ? record() : stopRecorder();
  }

  void onPlayPressed() {
    if (!_mPlayerIsInited || !_mplaybackReady || !_mRecorder.isStopped) {
      return;
    }

    _mPlayer.isStopped ? play() : stopPlayer();
  }

  void record() async {
    _timerController.reset();

    await _mRecorder.startRecorder(
      toFile: 'tau_file.mp4',
      codec: Codec.aacMP4,
      audioSource: AudioSource.microphone,
    );

    _timerController.start();

    setState(() {
      _mplaybackReady = false;
    });
  }

  void stopRecorder() async {
    await _mRecorder.stopRecorder();

    _timerController.stop();

    setState(() {
      _mplaybackReady = true;
    });
  }

  void play() async {
    if (!_mPlayerIsInited ||
        !_mplaybackReady ||
        !_mRecorder.isStopped ||
        !_mPlayer.isStopped) {
      return;
    }

    await _mPlayer.startPlayer(
      fromURI: 'tau_file.mp4',
      whenFinished: () {
        setState(() {});
      },
    );

    setState(() {});
  }

  void stopPlayer() async {
    if (!_mPlayerIsInited ||
        !_mplaybackReady ||
        !_mRecorder.isStopped ||
        _mPlayer.isStopped) {
      return;
    }

    await _mPlayer.stopPlayer();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      appBar: AppBar(
        title: const Text('Simple Recorder'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.all(3),
              padding: const EdgeInsets.all(3),
              height: 80,
              width: double.infinity,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Color(0xFFFAF0E6),
              ),
              child: Row(children: [
                ElevatedButton(
                  onPressed: onRecordPressed,
                  child: Icon(
                    _mRecorder.isRecording
                        ? Icons.stop_rounded
                        : Icons.keyboard_voice_rounded,
                  ),
                ),
                const SizedBox(
                  width: 20,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _mRecorder.isStopped
                          ? 'Record is stopped'
                          : 'Record in progress',
                    ),
                    ValueListenableBuilder<int>(
                      valueListenable: _timerController,
                      builder: (_, value, __) {
                        return Text(
                          '${_timerController.formattedTime}',
                        );
                      },
                    )
                  ],
                ),
              ]),
            ),
            Container(
              margin: const EdgeInsets.all(3),
              padding: const EdgeInsets.all(3),
              height: 80,
              width: double.infinity,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Color(0xFFFAF0E6),
              ),
              child: Row(children: [
                ElevatedButton(
                  onPressed: onPlayPressed,
                  child: Icon(
                    _mPlayer.isPlaying
                        ? Icons.stop_rounded
                        : Icons.play_arrow_rounded,
                  ),
                ),
                const SizedBox(
                  width: 20,
                ),
                Text(
                  _mPlayer.isStopped
                      ? 'Player is stopped'
                      : 'Playback in progress',
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
