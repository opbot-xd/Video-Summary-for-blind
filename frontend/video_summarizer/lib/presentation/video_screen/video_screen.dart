//import 'package:assets_audio_player/assets_audio_player.dart';
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

//dispose cameracontroller
class VideoScreen extends StatelessWidget{
  const VideoScreen({super.key});
  @override
  Widget build(BuildContext context){
    late var file;
    var video_id;
    bool recordingrn=false;
    String video2backurl="http://10.0.2.2:8000/api/upload";
    String sumFromBackUrl="http://10.0.2.2:8000/api/status/$video_id";
   // print(sumFromBackUrl);
    //final player=AudioPlayer();
    Future<void> play()async{
      print("hi");
    final player=AudioPlayer();
    await player.play(AssetSource("Button2record1.mp3"));
    }
    Future<void> playOnRecord()async{
      print("hi");
    final player=AudioPlayer();
    await player.play(AssetSource("RecordingHasStarted.mp3"));
    }
    Future<void> playOnRecordStop()async{
      print("hi");
    final player=AudioPlayer();
    await player.play(AssetSource("RecordStop.mp3"));
    }
    play();

    late CameraController _cameraController;
    void initfunc()async{
      final cameras=await availableCameras();
      final back=cameras.firstWhere((camera) => camera.lensDirection == CameraLensDirection.back);
      _cameraController = CameraController(back, ResolutionPreset.medium);
      await _cameraController.initialize();
      BlocProvider.of<VideoBloc>(context).add(Loaded());
    }

    initfunc();
    BlocListener<TimerBloc,TimerState>(
      
      listener:(context,state)async{
        print("called");
        if(state.timeron==true){
          print("tru");
          await Future.delayed(Duration(seconds:60));
          if(BlocProvider.of<TimerBloc>(context).state.timeron==true){
          file= await _cameraController.stopVideoRecording();
          //print(file);
          //BlocProvider.of<RecordBloc>(context).add(EndRecord());
          BlocProvider.of<TimerBloc>(context).add(timerEnd());
          VideoPlayerController con=new VideoPlayerController.file(file.path);
          await con.initialize();
          print("saveee");
          recordingrn=false;
          File fil=file.path;

          print(con.value.duration);
          playOnRecordStop();
          var sendingData={
                        "video_file":fil
                      };
                      try{
                        var response=await http.post(Uri.parse(video2backurl),
                        headers:{"Content-type":"application/json"},
                        body:jsonEncode(sendingData));
                        if(response.statusCode==201){
                          print("video sent");
                          //COnvert from strring to int
                          var body=jsonDecode(response.body) as Map<String,dynamic>;
                          video_id=body["video_id"];
                          void getsend()async{
                            await Future.delayed(const Duration(seconds: 10));
                            var response1=await http.get(Uri.parse(sumFromBackUrl));
                            if (response1.statusCode==200){
                              var bodyresp=json.decode(response1.body) as Map<String,dynamic>;
                              if(bodyresp["status"]=="Completed"){
                                var summary=bodyresp["summary"];
                                FlutterTts tts=FlutterTts();
                                tts.setLanguage("en-US");
                                tts.speak(summary);

                              }
                              else{
                                getsend();  
                              }


                            }else{
                              print("Omaewa erroru");
                            }


                          }
                          getsend();

                        }else{
                          print("An error happened");
                        }
                      }catch(e){
                        print("Error happened $e");
                      }
          
          }
        }


      } ,
    );

    
    
   // play();
    return  Scaffold(
      
      appBar:AppBar(title:const Text("Video Summarizer",
      style:TextStyle(color: Colors.white),),
      centerTitle: true,
      backgroundColor: Colors.cyan,),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            BlocBuilder<VideoBloc,VideoState>(
              builder:(context,state)=>(
                (state.isLoading==true)?SizedBox(height:300,width: 300, child:CircularProgressIndicator()):SizedBox(height:300,
                width:300,
                child: CameraPreview(_cameraController))
              ) ),
            //CameraPreview(_cameraController),
             
          SizedBox(
            height: 300,
            width:300,
            child: FloatingActionButton(
              shape:CircleBorder(),
              onPressed:()async{
                print("yohoo");
                
                    //if(state.isRecording==false){
                    if(!recordingrn){
                      print("why");
                      await _cameraController.prepareForVideoRecording();
                      await _cameraController.startVideoRecording();
                      //BlocProvider.of<RecordBloc>(context).add(StartRecord());
                      BlocProvider.of<TimerBloc>(context).add(timerStart());
                      recordingrn=true;
                      playOnRecord();
                    }else{
                      print("Hi");
                      file= await _cameraController.stopVideoRecording();
                      //BlocProvider.of<RecordBloc>(context).add(EndRecord());
                      BlocProvider.of<TimerBloc>(context).add(timerEnd());
                      File fil=File(file.path);
                      VideoPlayerController con=VideoPlayerController.file(fil);
                      await con.initialize();
                      print("saveee");
                      recordingrn=false;

                      print(con.value.duration);
                      playOnRecordStop();
                      var sendingData={
                        "video_file":fil
                      };
                      try{
                        var response=await http.post(Uri.parse(video2backurl),
                        headers:{"Content-type":"application/json"},
                        body:jsonEncode(sendingData));
                        if(response.statusCode==201){
                          print("video sent");
                          //COnvert from strring to int
                          var body=jsonDecode(response.body) as Map<String,dynamic>;
                          video_id=body["video_id"];
                          void getsend()async{
                            await Future.delayed(const Duration(seconds: 10));
                            var response1=await http.get(Uri.parse(sumFromBackUrl));
                            if (response1.statusCode==200){
                              var bodyresp=json.decode(response1.body) as Map<String,dynamic>;
                              if(bodyresp["status"]=="Completed"){
                                var summary=bodyresp["summary"];
                                FlutterTts tts=FlutterTts();
                                tts.setLanguage("en-US");
                                tts.speak(summary);

                              }
                              else{
                                getsend();  
                              }


                            }else{
                              print("Omaewa erroru");
                            }


                          }
                          getsend();

                        }else{
                          print("An error happened");
                        }
                      }catch(e){
                        print("Error happened $e");
                      }
                    }
                  
                
                //to prevent multiple clicks inshort tie 
                await Future.delayed(
                const Duration(milliseconds: 500));
                

                
              },
              child:const  Icon(Icons.add,
              size:100,
              color:Colors.white )),
          ),
         
        ]),
      ),
    );


  }
}
