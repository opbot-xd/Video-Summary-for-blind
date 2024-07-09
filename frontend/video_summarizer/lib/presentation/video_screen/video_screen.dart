//import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import "package:video_summarizer/presentation/video_screen/bloc/video_screen_bloc.dart";
import "package:video_summarizer/presentation/video_screen/bloc/video_screen_event.dart";
import "package:video_summarizer/presentation/video_screen/bloc/video_screen_state.dart";
import "package:video_player/video_player.dart";
//import "package:audioplayers/audioplayers.dart";
//import "package:assets_audio_player/assets_audio_player.dart";
//import "package:just_audio/just_audio.dart";
import 'package:camera/camera.dart';
import 'dart:io';
//dispose cameracontroller
class VideoScreen extends StatelessWidget{
  const VideoScreen({super.key});
  @override
  Widget build(BuildContext context){
    late var file;
    bool recordingrn=false;
    
    //final player=AudioPlayer();
    Future<void> play()async{
      print("hi");
   // String audpath="Button2record.mp3";
    //final player=AudioPlayer();
  //  await player.play(AssetSource("Button2record.mp3"));
    //final player2=new AudioCache("Button2record.mp3");
    //AudioCache aud=AudioCache();
    //audPla0
    //y=await aud.play("Button2record.mp3");
    //await player.dispose();
    
    //final duration=await player.setAsset("assets/Button2record.mp3");
    //player.play();

    }

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

          print(con.value.duration);
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
