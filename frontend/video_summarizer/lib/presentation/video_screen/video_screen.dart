import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import "package:audioplayers/audioplayers.dart";
import "package:assets_audio_player/assets_audio_player.dart";


class VideoScreen extends StatelessWidget{
  const VideoScreen({super.key});
  @override
  Widget build(BuildContext context){
    Future<void> play()async{
      print("hi");
   // String audpath="Button2record.mp3";
    //final player=AudioPlayer();
    //await player.play(AssetSource("Button2record.mp3"));
    //final player2=new AudioCache("Button2record.mp3");
    //AudioCache aud=AudioCache();
    //audPlay=await aud.play("Button2record.mp3");
    //await player.dispose();
      AssetsAudioPlayer.newPlayer().open(
      Audio("assets/Button2record.mp3"),
      autoStart: true,
      showNotification:false,
    );
    }
    play();

    return Scaffold(
      appBar:AppBar(title:const Text("Video Summarizer",
      style:TextStyle(color: Colors.white),),
      centerTitle: true,
      backgroundColor: Colors.cyan,),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
          
          Container(
            height: 300,
            width:300,
            child: FloatingActionButton(
              child: Icon(Icons.add,
              size:100,
              color:Colors.white ),
              shape:CircleBorder(),
              onPressed:(){}),
          )
        ]),
      ),
    );


  }
}
