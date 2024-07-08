import 'package:flutter/material.dart';
import "package:flutter_bloc/flutter_bloc.dart";
import "package:video_summarizer/presentation/video_screen/video_screen.dart";

void main(){
  WidgetsFlutterBinding.ensureInitialized();
  runApp( const MyApp());
}
class MyApp extends StatelessWidget{
  const MyApp({super.key});
  @override
  Widget build(BuildContext context){
    return MaterialApp(
      title:"Video Summarizer",
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      //define home here
      home: VideoScreen(),

    );
  }
}