import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import "package:video_summarizer/presentation/video_screen/bloc/video_screen_bloc.dart";
import "package:video_summarizer/presentation/video_screen/bloc/video_screen_event.dart";
import "package:video_summarizer/presentation/video_screen/bloc/video_screen_state.dart";
import "package:video_player/video_player.dart";
import "package:audioplayers/audioplayers.dart";
import 'package:camera/camera.dart';
import 'dart:io';
import "dart:convert";
import "package:http/http.dart" as http;
import 'package:flutter_tts/flutter_tts.dart';

class VideoScreen extends StatelessWidget {
  const VideoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    late var file;
    var video_id;
    bool recordingrn = false;
    String video2backurl = "http://192.168.1.5:8000/api/upload/";
    String sumFromBackUrl = "http://192.168.1.5:8000/api/status/";

    Future<void> play() async {
      final player = AudioPlayer();
      await player.play(AssetSource("Button2record1.mp3"));
    }

    Future<void> playOnRecord() async {
      final player = AudioPlayer();
      await player.play(AssetSource("RecordingHasStarted.mp3"));
    }

    Future<void> playOnRecordStop() async {
      final player = AudioPlayer();
      await player.play(AssetSource("RecordStop.mp3"));
    }

    play();

    late CameraController _cameraController;

    void initfunc() async {
      final cameras = await availableCameras();
      final back = cameras.firstWhere((camera) => camera.lensDirection == CameraLensDirection.back);
      _cameraController = CameraController(back, ResolutionPreset.medium);
      await _cameraController.initialize();
      BlocProvider.of<VideoBloc>(context).add(Loaded());
    }

    initfunc();

    Future<void> sendVideo(File videoFile) async {
      var request = http.MultipartRequest('POST', Uri.parse(video2backurl));
      request.headers['Content-Type'] = 'multipart/form-data';
      request.files.add(await http.MultipartFile.fromPath('video_file', videoFile.path));
      
      try {
        var response = await request.send();
        if (response.statusCode == 201) {
          var responseBody = await response.stream.bytesToString();
          var body = jsonDecode(responseBody) as Map<String, dynamic>;
          video_id = body["video_id"];
          void getsend() async {
            await Future.delayed(const Duration(seconds: 10));
            var response1 = await http.get(Uri.parse(sumFromBackUrl + video_id.toString()));
            if (response1.statusCode == 200) {
              var bodyresp = json.decode(response1.body) as Map<String, dynamic>;
              if (bodyresp["status"] == "Completed") {
                var summary = bodyresp["summary"];
                FlutterTts tts = FlutterTts();
                tts.setLanguage("en-US");
                tts.speak(summary);
              } else {
                getsend();
              }
            } else {
              print("Error retrieving summary");
            }
          }
          getsend();
        } else {
          print("An error occurred while sending the video");
        }
      } catch (e) {
        print("Error occurred: $e");
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Video Summarizer",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.cyan,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            BlocBuilder<VideoBloc, VideoState>(
              builder: (context, state) => (state.isLoading == true)
                  ? SizedBox(height: 300, width: 300, child: CircularProgressIndicator())
                  : SizedBox(height: 300, width: 300, child: CameraPreview(_cameraController)),
            ),
            SizedBox(
              height: 300,
              width: 300,
              child: FloatingActionButton(
                shape: CircleBorder(),
                onPressed: () async {
                  if (!recordingrn) {
                    await _cameraController.prepareForVideoRecording();
                    await _cameraController.startVideoRecording();
                    BlocProvider.of<TimerBloc>(context).add(timerStart());
                    recordingrn = true;
                    playOnRecord();
                  } else {
                    file = await _cameraController.stopVideoRecording();
                    BlocProvider.of<TimerBloc>(context).add(timerEnd());
                    File fil = File(file.path);
                    VideoPlayerController con = VideoPlayerController.file(fil);
                    await con.initialize();
                    recordingrn = false;
                    playOnRecordStop();
                    await sendVideo(fil);
                  }
                  await Future.delayed(const Duration(milliseconds: 500));
                },
                child: const Icon(Icons.add, size: 100, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
