abstract class VideoEvent{

}
class Loaded extends VideoEvent{}
abstract class RecordEvent{

}
class StartRecord extends RecordEvent{}
class EndRecord extends RecordEvent{}
abstract class TimerEvent{

}
class timerStart extends TimerEvent{}
class timerEnd extends TimerEvent{}