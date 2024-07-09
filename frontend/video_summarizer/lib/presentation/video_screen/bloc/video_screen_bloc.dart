//to do
/*
ek bloc to sidha banega loading state ke liye
isloading=true
intiailsise cameraconteoller
make a loading inndiactor 
 */
import "package:flutter_bloc/flutter_bloc.dart";
import "package:video_summarizer/presentation/video_screen/bloc/video_screen_event.dart";
import "package:video_summarizer/presentation/video_screen/bloc/video_screen_state.dart";

class VideoBloc extends Bloc<VideoEvent,VideoState>{
  VideoBloc():super(VideoState(true)){
    on<Loaded>((event,emit){
      emit(VideoState(false));//isLoading=false

    });

  }
}
class RecordBloc extends Bloc<RecordEvent,RecordState>{
  RecordBloc():super(RecordState(false)){
    on<StartRecord>((event,emit){
      emit(RecordState(true));
    });
    on<EndRecord>((event,emit){
      emit(RecordState(false));
    });
  }
}
class TimerBloc extends Bloc<TimerEvent,TimerState>{
   TimerBloc():super(TimerState(false)){
    on<timerEnd>((event,emit){
      emit(TimerState(false));

    });
    on<timerStart>((event,emit){
      emit(TimerState(true));

    });
   }
}